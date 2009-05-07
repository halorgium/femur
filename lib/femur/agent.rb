module Femur
  class Agent
    include Utils

    def self.run(user_id, secret)
      new(user_id, secret).run
    end

    def initialize(user_id, secret)
      @user_id, @secret = user_id, secret
      @master = "master"
      @client = Client.new(self)
      @identity = gen_token
      puts "setting identity to #{@identity}"
    end
    attr_reader :user_id, :identity

    def run
      @client.connect do
        own_queue.subscribe(:ack => true) do |message|
          on_message(message)
        end

        master_queue.publish(:advert, {:agent => self,
                                       :operations => ["soso"],
                                       :resources => {:host => "oeijsef"}})
      end
    end

    def verified?(content, signature)
      self_sign(content) == signature
    end

    def on_message(message)
      puts "Got message"
      case message
      when Messages::FromMaster
        puts "Checking a message from master"
        if verified?("#{identity}:#{message.correlation_id}:#{message.id}", message.signature)
          case message
          when Messages::AdvertOK
            puts "Got an AdvertOK"
          else
            puts "Not handling from master: #{message.inspect}"
          end
        else
          puts "BAD"
        end
      else
        puts "Not handling: #{message.inspect}"
      end
      pp message
    end

    def own_queue
      @own_queue ||= @client.queue(@identity, :exclusive => true)
    end

    def master_queue
      @master_queue ||= @client.queue(@master)
    end

    def dispatch(job)
      job.data "data"
      job.final
    end
  end
end
