module Hermes
  module Types
    struct MultiPolygon < IGeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(Array(Array(Array(Float64))))
      )

      def initialize(@coordinates)
        @type = "multi_polygon"
      end
    end
  end
end
