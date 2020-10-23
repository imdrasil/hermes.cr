module Hermes
  module Types
    struct MultiPolygon < IGeoShape
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property type : String

      @[JSON::Field(key: "coordinates")]
      property coordinates : Array(Array(Array(Float64)))

      def initialize(@coordinates)
        @type = "multi_polygon"
      end
    end
  end
end
