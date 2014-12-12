require 'bundler/setup'
Bundler.require

require './counter_api'
run Sinatra::Application
