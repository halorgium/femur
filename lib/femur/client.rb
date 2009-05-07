module Femur
  class Client
    def initialize(owner)
      @owner = owner
    end
    attr_reader :owner

    def connect
      AMQP.start(:host => 'localhost', :logging => ENV["AMQP_DEBUG"] == "true") do
        yield
      end
    end

    def channel
      @channel = MQ.new
    end

    def queue(*args)
      Queue.new(channel, *args)
    end
  end
end
