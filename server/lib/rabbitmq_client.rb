class RabbitmqClient
  attr_reader :connection, :channel, :exchange, :queue

  def initialize
    @connection = Bunny.new
    @connection.start
  end

  def start(queue_name)
    @queue ||= channel.queue(queue_name)

    queue.subscribe do |_delivery_info, properties, _payload|
      message = yield

      # exchange
      #   .publish(
      #     message,
      #     routing_key: properties.reply_to,
      #     correlation_id: properties.correlation_id
      #   )
    end
  end

  def stop
    channel.close
    connection.close
  end

  private


  def channel
    @channel ||= connection.create_channel
  end

  def exchange
    @exchange ||= channel.default_exchange
  end
end
