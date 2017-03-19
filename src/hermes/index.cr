module Hermes
  class Index
    alias OptionValue = String | Symbol | Int32 | Float32 | Float64 | Time | Hash(Symbol | String, OptionValue)

    @@config = {} of Symbol | String => OptionValue

    INDEXES = [] of typeof(self)

    def self.index_name
      @@name ||= self.to_s.gsub(/Index$/, "").underscore
    end

    def self.index_name(_name : String)
      @@name = _name
    end

    def self.settings
      config[:settings]? || config["settings"]?
    end

    def self.mappings
      config[:mappings]? || config["mappings"]?
    end

    def self.config(hash)
      @@config = Hermes.deep_hash_converting(hash)
    end

    def self.config : Hash(Symbol | String, OptionValue)
      @@config
    end

    def self.refresh
      Hermes.client.post("/#{index_name}/_refresh")
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

    def self.info
      Hermes.client.get("/#{index_name}")
    end

    def self.create
      Hermes.client.put(index_name, nil, config.to_json)
    end

    def self.update_settings
      Hermes.client.put("/#{index_name}/_settings", nil, settings.to_json) if settings
    end

    def self.update_mapping
      raise "Mapping is not specified" unless mappings
      Hermes.client.put("/#{index_name}", nil, mappings.to_json)
    end

    def self.update
      update_settings
      update_mapping
    end

    def self.destroy
      Hermes.client.delete("/#{index_name}")
    end

    def self.stats
      Hermes.client.get("/#{index_name}/_stats")
    end

    macro inherited
      INDEXES << {{@type}}
    end
  end
end
