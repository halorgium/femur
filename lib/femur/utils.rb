module Femur
  module Utils
    def gen_token
      HMAC::SHA256.hexdigest(Time.now.to_f.to_s, DateTime.now.ajd.to_f.to_s)
    end

    def self_sign(content)
      sign(@secret, content)
    end

    def sign(secret, content)
      HMAC::SHA512.hexdigest(secret, content)
    end
  end
end
