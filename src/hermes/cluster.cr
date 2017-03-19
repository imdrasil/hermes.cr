module Hermes
  module Cluster
    extend self

    def health
      Hermes.client.get("/_cluster/health")
    end

    def stats
      Hermes.client.get("/_cluster/stats?human&pretty")
    end

    def state
      Hermes.client.get("/_cluster/state")
    end

    def add_alias(index, _alias)
      Hermes.client.post("/_aliases", nil, {actions: [{add: {index: index, alias: _alias}}]}.to_json)
    end

    def add_alias(indexes : Array(String), _alias)
      Hermes.client.post("/_aliases", nil, {actions: [{add: {indexes: indexes, alias: _alias}}]}.to_json)
    end

    def remove_alias(indexes : Array(String), _alias)
      Hermes.client.post("/_aliases", nil, {actions: [{remove: {indexes: indexes, alias: _alias}}]}.to_json)
    end

    def remove_alias(index, _alias)
      Hermes.client.post("/_aliases", nil, {actions: [{remove: {index: index, alias: _alias}}]}.to_json)
    end
  end
end
