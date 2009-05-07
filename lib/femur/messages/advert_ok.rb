module Femur
  module Messages
    class AdvertOK < FromMaster
      register :advert_ok

      def process(options)
        super
        set :response, true
      end
    end
  end
end
