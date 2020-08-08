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

    # JSON.mapping(
    #   _index: String,
    #   _type: String,
    #   _id: String,
    #   _source: T
    # )

    # def self.new(pull : JSON::PullParser)
      # instance = Hit(T).allocate
      # p instance
      # instance.initialize(pull)
      # instance._source._id = instance._id
      # instance._source._type = instance._type
      # instance._source._index = instance._index
      # instance
    # end

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
    property total : Int32


    @[JSON::Field(key: "max_score")]
    property max_score : Float32?

    @[JSON::Field(key: "hits")]
    property hits : Array(Hit(T))

    # JSON.mapping(
    #   total: Int32,
    #   max_score: Float32?,
    #   hits: Array(Hit(T))
    # )
  end

  struct SearchResponse(T)
    include JSON::Serializable

    @[JSON::Field(key: "hits")]
    property hits : Hits(T)

    @[JSON::Field(key: "aggregations")]
    property aggregations : Hash(String, JSON::Any)?

    # JSON.mapping(
    #   hits: Hits(T),
    #   aggregations: {type: Hash(String, JSON::Any), nilable: true}

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
    
    # JSON.mapping(
    #   aggregations: Hash(String, JSON::Any)
    # )

    def aggs
      @aggregations
    end
  end

  struct MultiGetResponse(T)
    include JSON::Serializable

    @[JSON::Field(key: "docs")]
    property docs : Array(Hit(T))

    # JSON.mapping(
    #   docs: Array(Hit(T))
    # )

    def entries
      @docs.map(&._source)
    end
  end
end
