module Hermes
  module Types
    class MultiPolygon
      JSON.mapping(
        type: String,
        coordinates: Array(Array(Array(Array(Float32))))
      )
    end
  end
end
