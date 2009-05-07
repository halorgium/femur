module Femur
  class Master
    include Utils

    CREDS = {
      "user" => "secret"
    }

    def self.run
      new.run
    end

    def initialize
      @master = "master"
      @client = Client.new(self)
    end

    def run
      @client.connect do
        master_queue.subscribe(:ack => true) do |message|
          on_message(message)
        end
      end
    end

    def verified?(user_id, content, signature)
      sign_for(user_id, content) == signature
    end

    def sign_for(user_id, content)
      if secret = CREDS[user_id]
        sign(secret, content)
      end
    end

    def on_message(message)
      case message
      when Messages::FromAgent
        puts "#{message.class} from #{message.user_id} on #{message.identity}"
        if verified?(message.user_id, "#{message.identity}:#{message.id}", message.signature)
          case message
          when Messages::Advert
            puts "OK"
            @client.queue(message.identity).publish(:advert_ok, {:master => self,
                                                                 :in_reply_to => message})
          else
            puts "Not handling from agent: #{message.inspect}"
          end
        else
          puts "BAD"
        end
      else
        puts "Not handling: #{message.inspect}"
      end
    end

    def master_queue
      @master_queue ||= @client.queue(@master, :exclusive => true)
    end
  end
end
