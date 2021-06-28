module Hermes
  # TODO: probably should switch to struct but need to check case with high load
  struct Hit(T)
    include JSON::Serializable

    @[JSON::Field(key: "_index")]
    property _index : String

    @[JSON::Field(key: "_type")]
    property _type : String

    @[JSON::Field(key: "_id")]
    property _id : String

    @[JSON::Field(key: "_source")]
    @_source : T

    def _source
      @_source._id = @_id
      @_source._type = @_type
      @_source._index = @_index

      @_source
    end

    def entry
      _source
    end
  end

  struct Hits(T)
    include JSON::Serializable

    @[JSON::Field(key: "total")]
    property total : Int32 | Hash(String, JSON::Any)

    @[JSON::Field(key: "max_score")]
    property max_score : Float32?

    @[JSON::Field(key: "hits")]
    property hits : Array(Hit(T))
  end

  struct SearchResponse(T)
    include JSON::Serializable

    @[JSON::Field(key: "hits")]
    property hits : Hits(T)

    @[JSON::Field(key: "aggregations")]
    property aggregations : Hash(String, JSON::Any)?

    def entries
      @hits.hits.map(&._source)
    end

    def aggs
      @aggregations
    end
  end

  struct AggregationResponse
    include JSON::Serializable

    @[JSON::Field(key: "aggregations")]
    property aggregations : Hash(String, JSON::Any)

    def aggs
      @aggregations
    end
  end

  struct MultiGetResponse(T)
    include JSON::Serializable

    @[JSON::Field(key: "docs")]
    property docs : Array(Hit(T))

    def entries
      @docs.map(&._source)
    end
  end
end
