module Hermes
  module Types
    class Point
      JSON.mapping(
        type: String,
        coordinates: Array(Float32)
      )
    end
  end
end
