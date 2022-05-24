class RabbitmqClient
  attr_accessor :call_id, :response, :lock, :condition, :connection,
                :channel, :server_queue_name, :reply_queue, :exchange

  def initialize(server_queue_name)
    @connection = Bunny.new(automatically_recover: false)
    @server_queue_name = server_queue_name
    
    @connection.start
    
    setup_reply_queue
  end

  def start(light_status:)
    @call_id = uuid

    exchange.publish(light_status.to_s,
                     routing_key: server_queue_name,
                     correlation_id: call_id,
                     reply_to: reply_queue.name)

    lock.synchronize { condition.wait(lock) }

    response
  end

  def stop
    channel.close
    connection.close
  end

  private
  
  def setup_reply_queue
    @lock = Mutex.new
    @condition = ConditionVariable.new
    @reply_queue = channel.queue('', exclusive: true)
    that = self

    reply_queue.subscribe do |_delivery_info, properties, payload|
      if properties[:correlation_id] == that.call_id
        that.response = payload.to_s
        that.lock.synchronize { that.condition.signal }
      end
    end
  end

  def uuid
    SecureRandom.uuid
  end

  def channel
    @channel ||= connection.create_channel
  end

  def exchange
    @exchange ||= channel.default_exchange
  end
end
