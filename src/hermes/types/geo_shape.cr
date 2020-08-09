module Hermes
  module Types
    abstract struct IGeoShape
      abstract def type
      abstract def coordinates
    end

    struct GeoShape < IGeoShape
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property type : String

      @[JSON::Field(key: "coordinates")]
      property coordinates : Array(JSON::Any)

      def initialize(@coordinates)
        @type = "geo_shape"
      end
    end
  end
end
