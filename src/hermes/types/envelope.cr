module Hermes
  module Types
    struct Envelope < IGeoShape
      include JSON::Serializable

      @[JSON::Field(key: "type")]
      property type : String

      @[JSON::Field(key: "coordinates")]
      property coordinates : Array(Array(Float64))

      def initialize(@coordinates)
        @type = "envelope"
      end
    end
  end
end
