require "sinatra/json"

configure do
  session ||= Moped::Session.connect(ENV.fetch('MONGOSOUP_URL', '127.0.0.1:27017'))
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
