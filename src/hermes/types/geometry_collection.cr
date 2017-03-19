require "./geo_shape"

module Hermes
  module Types
    struct GeometryCollection
      JSON.mapping(
        type: String,
        geometries: Array(GeoShape)
      )

      def initialize(@geometries)
        @type = "geometry_collection"
      end
    end
  end
end
