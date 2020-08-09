module Hermes
  module Types
    struct MultiPoint < IGeoShape
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property type : String

      @[JSON::Field(key: "coordinates")]
      property coordinates : Array(Array(Float64))

      def initialize(@coordinates)
        @type = "multi_point"
      end
    end
  end
end
