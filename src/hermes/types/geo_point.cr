module Hermes
  module Types
    struct GeoPoint
      JSON.mapping(
        lat: Float64,
        lon: Float64
      )

      def initialize(@lat, @lon)
      end
    end
  end
end
