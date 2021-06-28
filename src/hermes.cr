require "json"
require "http/client"

require "./hermes/config"

require "./hermes/types/range"
require "./hermes/types/geo_shape"
require "./hermes/types/multi_point"
require "./hermes/types/*"

require "./hermes/response"
require "./hermes/client"
require "./hermes/*"

module Hermes
  VERSION = "0.3.1"

  def self.status
    client.get("/")
  end

  def self.refresh
    Hermes.client.post("/_refresh")
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

  def self.bulk(hashes)
    body = String.build do |s|
      hashes.each do |hash|
        hash.to_json(s)
        s << "\n"
      end
    end
    client.post("/_bulk", nil, body)
  end

  def self.deep_hash_converting(hash)
    temp = {} of Symbol | String => Index::OptionValue
    hash.keys.each do |k|
      v = hash[k]
      temp[k] =
        if v.is_a?(Hash) || v.is_a?(NamedTuple)
          deep_hash_converting(v)
        else
          v
        end
    end
    temp
  end
end
