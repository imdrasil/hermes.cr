module Hermes
  module Types
    class MultiPoint
      JSON.mapping(
        type: String,
        coordinates: Array(Array(Float32))
      )
    end
  end
end
