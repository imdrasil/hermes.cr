module Hermes
  module Types
    struct Range(T)
      include JSON::Serializable

      @[JSON::Field(key: "lte")]
      property lte : T

      @[JSON::Field(key: "gte")]
      property gte : T

      def initialize(@lte, @gte)
      end
    end
  end
end
