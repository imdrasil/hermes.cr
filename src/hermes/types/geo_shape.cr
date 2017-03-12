module Hermes
  module Types
    class GeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(JSON::Any)
      )
    end
  end
end
