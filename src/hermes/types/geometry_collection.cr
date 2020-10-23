require "./geo_shape"

module Hermes
  module Types
    struct GeometryCollection
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property type : String

      @[JSON::Field(key: "geometries")]
      property geometries : Array(GeoShape)

      def initialize(@geometries)
        @type = "geometry_collection"
      end
    end
  end
end
