require "./multi_line_string"

module Hermes
  module Types
    struct Polygon < IGeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(Array(Array(Float64)))
      )

      def initialize(@coordinates)
        @type = "polygon"
      end
    end
  end
end
