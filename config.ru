require 'bundler/setup'
Bundler.require

$:.unshift File.expand_path('../lib', __FILE__)
require './counter_api'
run CounterApi
