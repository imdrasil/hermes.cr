module Hermes
  module Types
    class Circle
      JSON.mapping(
        type: String,
        coordinates: Array(Float32),
        radius: String
      )

      def r
        @r ||= @radius.gsub(/(\w)*$/, "").to_f
      end

      def unit
        @unit ||= @radius.gsub(/^[\d\.]*/, "")
      end
    end
  end
end
