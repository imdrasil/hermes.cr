module Hermes
  module Types
    struct LineString < IGeoShape
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property type : String

      @[JSON::Field(key: "coordinates")]
      property coordinates : Array(Array(Float64))

      # JSON.mapping(
      #   type: String,
      #   coordinates: Array(Array(Float64))
      # )

      def initialize(@coordinates)
        @type = "line_string"
      end
    end
  end
end
