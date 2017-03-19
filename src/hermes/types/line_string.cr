module Hermes
  module Types
    struct LineString < IGeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(Array(Float64))
      )

      def initialize(@coordinates)
        @type = "line_string"
      end
    end
  end
end
