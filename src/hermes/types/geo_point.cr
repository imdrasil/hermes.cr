module Hermes
  module Types
    class GeoPoint
      JSON.mapping(
        lat: Float32,
        lon: Float32
      )
    end
  end
end
