#!/usr/bin/env ruby

require 'bundler/setup'
require 'thread'
require 'securerandom'
require 'pry'
require './lib/rabbitmq_client'

Bundler.require(:default)

client = RabbitmqClient.new('lights')

puts ' [x] Send Lights status'
binding.pry
response = client.start(light_status: 'on')
puts " [.] Got #{response}"

client.stop
