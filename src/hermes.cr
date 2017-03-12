require "json"
require "http/client"
require "./hermes/config"
require "./hermes/types/range"
require "./hermes/types/multi_point"
require "./hermes/types/*"
require "./hermes/response"
require "./hermes/client"
require "./hermes/*"

module Hermes
  def self.status
    client.get("/")
  end

  def self.cluster_health
    client.get("/_cluster/health")
  end

  def self.client
    @@client ||= Client.new
  end

  def self.search(indexes, types, hash)
    client.get("/#{indexes.join(",")}/#{types.join(",")}/_search", nil, hash.to_json)
  end

  def self.search(indexes, hash)
    client.get("/#{indexes.join(",")}/_search", nil, hash.to_json)
  end

  def self.search(hash)
    client.get("/_search", nil, hash.to_json)
  end
end
