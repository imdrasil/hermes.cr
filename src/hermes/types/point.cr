module Hermes
  module Types
    struct Point < IGeoShape
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property type : String

      @[JSON::Field(key: "coordinates")]
      property coordinates : Array(Float64)

      def initialize(@coordinates)
        @type = "point"
      end
    end
  end
end
