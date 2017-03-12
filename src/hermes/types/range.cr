module Hermes
  module Types
    class Range(T)
      JSON.mapping(
        lte: T,
        gte: T
      )
    end
  end
end
