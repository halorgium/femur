module Femur
  module Messages
    class FromMaster < Message
      def process(options)
        super
        return unless original?
        master = options[:master]
        in_reply_to = options[:in_reply_to]
        property :correlation_id, in_reply_to.id
        header :signature, master.sign_for(in_reply_to.user_id, "#{in_reply_to.identity}:#{in_reply_to.id}:#{id}")
      end

      def user_id
        headers[:user_id]
      end

      def correlation_id
        properties[:correlation_id]
      end

      def signature
        headers[:signature]
      end
    end
  end
end
