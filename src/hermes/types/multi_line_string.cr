module Hermes
  module Types
    class MultiLineString
      JSON.mapping(
        type: String,
        coordinates: Array(Array(Array(Float32)))
      )
    end
  end
end
