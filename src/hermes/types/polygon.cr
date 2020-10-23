require "./multi_line_string"

module Hermes
  module Types
    struct Polygon < IGeoShape
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property type : String

      @[JSON::Field(key: "coordinates")]
      property coordinates : Array(Array(Array(Float64)))

      def initialize(@coordinates)
        @type = "polygon"
      end
    end
  end
end
