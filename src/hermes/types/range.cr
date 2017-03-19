module Hermes
  module Types
    struct Range(T)
      JSON.mapping(
        lte: T,
        gte: T
      )

      def initialize(@lte, @gte)
      end
    end
  end
end
