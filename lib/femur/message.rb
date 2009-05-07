module Femur
  class Message
    include Utils

    def self.registered
      @registered ||= {}
    end

    def self.register(type)
      type = type.to_s
      if klass = Message.registered[type]
        raise "Already registered #{klass} for type: #{type.inspect}"
      end
      Message.registered[type] = self
      @type = type
    end

    def self.type
      @type || raise("No type set for #{self}")
    end

    def self.create(type, options)
      find(type).new({}, {}).create(options)
    end

    def self.reconstruct(type, content, properties)
      find(type).new(content, properties)
    end

    def self.find(type)
      type = type.to_s
      klass = Message.registered[type]
      raise "No such message for type: #{type.inspect}" unless klass
      klass
    end

    def initialize(content, properties)
      @content, @properties = content.to_mash, properties.to_mash
      if headers = @properties[:headers]
        @properties[:headers] = headers.to_mash
      end
    end
    attr_reader :properties

    def create(options)
      process(options)
      self
    end

    def original?
      !@complete
    end

    def id
      @properties[:message_id] ||= gen_token
    end

    def set(key, value)
      @content[key] = value
    end

    def headers
      @properties[:headers] ||= Mash.new
    end

    def property(key, value)
      @properties[key] = value
    end

    def header(key, value)
      headers[key] = value
    end

    def process(options)
      property :message_id, id
      property :type, self.class.type
    end

    def body
      @content.to_json
    end
  end
end
