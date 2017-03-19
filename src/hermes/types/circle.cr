module Hermes
  module Types
    struct Circle < IGeoShape
      JSON.mapping(
        type: String,
        coordinates: Array(Float64),
        radius: String
      )

      def initialize(@coordinates, @radius)
        @type = "circle"
      end

      def r
        @r ||= @radius.gsub(/(\w)*$/, "").to_f
      end

      def unit
        @unit ||= @radius.gsub(/^[\d\.]*/, "")
      end
    end
  end
end
