module Hermes
  module Types
    struct MultiPoint < IGeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(Array(Float64))
      )

      def initialize(@coordinates)
        @type = "multi_point"
      end
    end
  end
end
