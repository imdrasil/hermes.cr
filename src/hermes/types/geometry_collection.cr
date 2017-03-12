require "./geo_shape"

module Hermes
  module Types
    class GeometryCollection
      JSON.mapping(
        type: String,
        geometries: Array(GeoShape)
      )
    end
  end
end
