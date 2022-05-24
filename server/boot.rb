require 'bundler/setup'
require './lib/rabbitmq_client'
require './lib/lights_response'

Bundler.require(:default)

begin
  puts 'Awaiting RPC requests'
  rabbitmq_client = RabbitmqClient.new

  rabbitmq_client.start('lights') do
    LigthsResponse.new.switch
  end

  loop { sleep 4 }

rescue Interrupt =>
  rabbitmq_client.stop
end
