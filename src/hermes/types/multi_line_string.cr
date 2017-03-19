module Hermes
  module Types
    struct MultiLineString < IGeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(Array(Array(Float64)))
      )

      def initialize(@coordinates)
        @type = "multi_line_string"
      end
    end
  end
end
