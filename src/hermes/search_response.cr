module Hermes
  # TODO: probably should switch to struct but need to check case with high load
  struct Hit(T)
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

    def entry
      _source
    end
  end

  struct Hits(T)
    JSON.mapping(
      total: Int32,
      max_score: Float32?,
      hits: Array(Hit(T))
    )
  end

  struct SearchResponse(T)
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

  struct AggregationResponse
    JSON.mapping(
      aggregations: Hash(String, JSON::Any)
    )

    def aggs
      @aggregations
    end
  end

  struct MultiGetResponse(T)
    JSON.mapping(
      docs: Array(Hit(T))
    )

    def entries
      @docs.map(&._source)
    end
  end
end
