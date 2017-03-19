module Hermes
  module Types
    struct Envelope < IGeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(Array(Float64))
      )

      def initialize(@coordinates)
        @type = "envelope"
      end
    end
  end
end
