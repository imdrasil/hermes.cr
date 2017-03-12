require "base64"

module Hermes
  module Types
    struct Binary
      getter raw

      def initialize(@raw)
      end

      def initialize(pull : JSON::PullParser)
        @raw = pull.read_string
      end

      def self.encode(data)
        new(Base64.encode(data))
      end

      def self.strict_encode(data)
        new(Base64.strict_encode(data))
      end

      def decode
        Base64.decode(@raw)
      end
    end
  end
end
