module Hermes
  module Types
    struct Point < IGeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(Float64)
      )

      def initialize(@coordinates)
        @type = "point"
      end
    end
  end
end
