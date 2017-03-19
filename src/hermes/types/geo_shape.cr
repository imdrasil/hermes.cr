module Hermes
  module Types
    abstract struct IGeoShape
      abstract def type
      abstract def coordinates
    end

    struct GeoShape < IGeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(JSON::Any)
      )

      def initialize(@coordinates)
        @type = "geo_shape"
      end
    end
  end
end
