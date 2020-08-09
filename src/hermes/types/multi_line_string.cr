module Hermes
  module Types
    struct MultiLineString < IGeoShape
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property type : String

      @[JSON::Field(key: "coordinates")]
      property coordinates : Array(Array(Array(Float64)))

      def initialize(@coordinates)
        @type = "multi_line_string"
      end
    end
  end
end
