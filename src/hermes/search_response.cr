module Hermes
  class Hit(T)
    JSON.mapping(
      _index: String,
      _type: String,
      _id: String,
      _source: T
    )

    def self.new(pull : JSON::PullParser)
      instance = Hit(T).allocate
      instance.initialize(pull)
      instance._source._id = instance._id
      instance._source._type = instance._type
      instance._source._index = instance._index
      instance
    end
  end

  class Hits(T)
    JSON.mapping(
      total: Int32,
      max_score: Float32?,
      hits: Array(Hit(T))
    )
  end

  class SearchResponse(T)
    JSON.mapping(
      hits: Hits(T),
      aggregations: {type: Hash(String, JSON::Any), nilable: true}
    )

    def entries
      hits.hits.map(&._source)
    end

    def aggs
      @aggregations
    end
  end
end
