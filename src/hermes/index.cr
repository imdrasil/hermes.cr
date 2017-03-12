module Hermes
  class Index
    alias Rightable = String | Int32 | Float32 | Hash(String | Symbol, Rightable)
    INDEXES = [] of typeof(::Hermes::Index)

    def self.index_name
      @@name ||= self.to_s.gsub(/Index$/, "").underscore
    end

    def self.index_name(_name : String)
      @@name = _name
    end

    def self.mapping(hash)
      @@mapping = hash
    end

    def self.mapping
      @@mapping ||= {} of String | Symbol => Rightable
    end

    def self.search(hash)
      Hermes.client.get("/#{index_name}/_search", nil, hash.to_json)
    end

    def self.search(types, hash)
      Hermes.client.get("/#{index_name}/#{types.join(",")}/_search", nil, hash.to_json)
    end

    def self.get_mapping
      Hermes.client.get("/#{index_name}/_mapping")
    end

    macro inherited
      {{Hermes::Index::INDEXES << @type}}
    end
  end
end
