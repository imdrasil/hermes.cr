module Hermes
  module Types
    struct GeoPoint
      include JSON::Serializable

      @[JSON::Field(key: "lat")]
      property lat : Float64

      @[JSON::Field(key: "lon")]
      property lon : Float64

      # JSON.mapping(
      #   lat: Float64,
      #   lon: Float64
      # )

      def initialize(@lat, @lon)
      end
    end
  end
end
