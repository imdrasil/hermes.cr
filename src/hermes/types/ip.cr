module Hermes
  module Types
    class IP
      getter raw

      def initialize(@raw)
      end

      def initialize(pull : JSON::PullParser)
        @raw = pull.read_string
      end
    end
  end
end
