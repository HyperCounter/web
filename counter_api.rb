require "sinatra/json"
require 'json'
require 'rack/contrib/bounce_favicon'
require 'rack/json_body_parser'
require 'active_support/core_ext/hash/slice'

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
    $session ||= Moped::Session.connect(ENV.fetch('MONGOSOUP_URL', 'mongodb://127.0.0.1:27017/cloud_counter'))
    $counters = $session['counters']
    disable :raise_errors
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
      counter.slice('name', 'value', 'accountId').tap do |result|
        result['id'] = counter['_id'].to_s
      end
    end
  end

  error ParameterMissingError do |e|
    json_error e, 400
  end

  get '/counters' do
    account_id = extract!('accountId')
    counters = $counters.find({accountId: account_id})
    json counters.map {|c| visible_members_of(c) }
  end

  post '/counters' do
    counter_params = visible_members_of(params)
    counter_params['events'] = []
    counter_params['value'] = params['initialValue'] || 0

    new_counter = $session.with(safe: true) do
      $counters.insert(counter_params)
    end

    json new_counter
  end

  get '/counters/:id' do |id|
    json ({id: 'x', name: 'x', value: 0})
  end

  put '/counters/:id' do |id|
    json ({id: 'x', name: 'x', value: 0}), status: 400
  end

end
