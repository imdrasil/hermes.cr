module Hermes
  module Types
    struct IP
      getter raw

      def initialize(@raw)
      end

      def initialize(pull : JSON::PullParser)
        @raw = pull.read_string
      end

      def to_json(json : JSON::Builder)
        json.string(@raw)
      end
    end
  end
end
