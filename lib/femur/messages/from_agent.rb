module Femur
  module Messages
    class FromAgent < Message
      def process(options)
        super
        return unless original?
        agent = options[:agent]
        property :reply_to, agent.identity
        property :user_id, agent.user_id
        header :signature, agent.self_sign("#{identity}:#{id}")
      end

      def user_id
        properties[:user_id]
      end

      def signature
        headers[:signature]
      end

      def identity
        properties[:reply_to]
      end
    end
  end
end
