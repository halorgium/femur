module Femur
  module Messages
    class Advert < FromAgent
      register :advert

      def process(options)
        super
        set :operations, options[:operations]
        set :resources, options[:resources]
      end
    end
  end
end
