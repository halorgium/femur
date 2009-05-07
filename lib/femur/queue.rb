module Femur
  class Queue
    def initialize(channel, *args)
      @queue = channel.queue(*args)
    end

    def subscribe(*args)
      @queue.subscribe(*args) do |header,message|
        type = header.properties[:type]
        content = JSON.parse(message)
        yield Message.reconstruct(type, content, header.properties)
      end
    end

    def publish(type, *args)
      message = Message.create(type, *args)
      @queue.publish(message.body, message.properties)
    end
  end
end
