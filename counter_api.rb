require "sinatra/json"

configure do
  session = Moped::Session.new([ '127.0.0.1:27017' ])
  session.use "cloud_counter_#{ENV['RACK_ENV']}"
end

post '/counters' do
  json ({id: 'x', name: 'x', value: 0})
end

get '/counters/:id' do |id|
  json ({id: 'x', name: 'x', value: 0})
end

put '/counters/:id' do |id|
  json ({id: 'x', name: 'x', value: 0})
end
