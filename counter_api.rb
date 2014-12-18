require "sinatra/json"
require 'json'
require 'rack/contrib/bounce_favicon'
require 'rack/json_body_parser'
require 'active_support/core_ext/hash/slice'
require "net/http"
require "uri"

# raised by extract! used if POST /photos does not include a `photo`
# key
class ParameterMissingError < StandardError
  def initialize(key)
    @key = key
  end

  def to_s
    %Q{Request did not provide "#{@key}"}
  end
end

class CounterApi < Sinatra::Base
  use Rack::BounceFavicon
  use Rack::JsonBodyParser

  configure do
    $session ||= Moped::Session.connect(ENV.fetch('MONGOSOUP_URL', 'mongodb://127.0.0.1:27017/hyper_counter'))
    $counters = $session['counters']
    # egy uj collection-ben egyetlen mezo, amit findAndUpdate-el novelgetunk
    # $inc, majd azt az erteket hasznaljuk hex-e konvertalva friendly id-kent
    $counters.indexes.create({id: 1}, {unique: true, dropDups: true})
    disable :show_exceptions
    enable :static
  end

  helpers Sinatra::JSON
  helpers do
    # Keep clients honest by forcing them to send the correct params
    def extract!(key)
      params.fetch(key.to_s) { raise ParameterMissingError, key }
    end

    def json_error(ex, code, errors = {})
      halt code, { 'Content-Type' => 'application/json' }, json({
        message: ex.message
      }.merge(errors))
    end

    # Helper abort an request from an exception
    def halt_json_error(code, errors = {})
      json_error env.fetch('sinatra.error'), code, errors
    end

    def visible_members_of(counter)
      counter.slice('id', 'name', 'value', 'accountId')
    end

    def render_counter(id)
      if counter = $counters.find({id: id}).one
        json visible_members_of(counter)
      else
        json_error StandardError.new, 404, {message: "Counter with id='#{id}' not found"}
      end
    end
  end

  error ParameterMissingError do |e|
    json_error e, 400
  end

  error Moped::Errors::OperationFailure do |e|
    json_error e, 400
  end

  get '/' do
    counters = $counters.find()
    erb :index
  end

  get '/counters' do
    # account_id = extract!('accountId')
    # counters = $counters.find({accountId: account_id})
    counters = $counters.find()
    json counters.map {|c| visible_members_of(c) }
  end

  get '/counters/:id' do |id|
    render_counter(id)
  end

  post '/counters' do
    counter_params           = visible_members_of(params)
    counter_params['events'] = []
    counter_params['value']  = params.fetch('initialValue', 0).to_i

    $session.with(safe: true) do
      $counters.insert(counter_params)
    end

    if created = $counters.find({id: counter_params['id']}).one
      json visible_members_of(created)
    else
      json_erros StandardError.new, 418, {message: 'Cannot create counter'}
    end
  end

  put '/counters/:id' do |id|
    timestamp = Time.at(params.fetch('timestamp') { Time.now.to_i }.to_i).utc
    delta     = extract!('delta').to_i

    $counters.find({id: id}).update({
      '$inc' => {'value' => delta},
      '$push' => {events: {timestamp: timestamp, delta: delta}}
    })

    begin
      Thread.new do
        uri = URI.parse('http://dig-scala.herokuapp.com/hyperApi')
        counter = $counters.find({id: id}).one
        name = counter ? counter['name'] : ''
        Net::HTTP.post_form(uri, name: name)
      end
    end

    render_counter(id)
  end

  get '/:account_id' do |account_id|
    @account_id = account_id
    counters = $counters.find({accountId: account_id})
    erb :index
  end

end
