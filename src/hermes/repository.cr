module Hermes
  class Repository(I, T)
    def self.document_index
      I.index_name
    end

    def self.document_type(name)
      @@document_type = name
    end

    def self.refresh
      Hermes.client.get(path("_refresh"))
    end

    def self.update(id, hash)
      Hermes.client.post(path(id, "_update"), nil, hash.to_json)
    end

    def self.update_by_query(hash)
      Hermes.client.post(path("_update_by_query"), nil, hash.to_json)
    end

    def self.search(hash)
      res = Hermes.client.get(path("_search"), nil, hash.to_json)
      SearchResponse(T).from_json(res.body)
    end

    def self.aggregate(hash)
      res = Hermes.client.get(path("_search"), nil, {size: 0, aggs: hash}.to_json)
      SearchResponse(T).from_json(res.body)
    end

    def self.explain(id, hash)
      Hermes.client.get(path(id, "_explain"), nil, hash.to_json)
    end

    def self.find(id : String)
      res = Hermes.client.get(path(id))
      if res.status == 404
        nil
      else
        Hit(T).from_json(res.body)._source
      end
    end

    def self.find!(id)
      Hit(T).from_json(Hermes.client.get!(path(id)).body)._source
    end

    def self.delete(id)
      Hermes.client.delete(path(id))
    end

    def self.delete!(id)
      Hermes.client.delete!(path(id))
    end

    def self.delete_by_query(hash)
      Hermes.client.delete(path("_delete_by_query"), nil, hash.to_json)
    end

    def self.create(hash)
      save(T.new(hash))
    end

    def self.count(hash)
      res = Hermes.client.get!(path("_count"), nil, hash.to_json)
      res.json["count"].as_i
    end

    def self.save(obj : Persistent)
      body = obj.to_json
      if obj._id && !obj._id.empty?
        Hermes.client.put(path(obj._id), nil, body)
      else
        res = Hermes.client.post(path, nil, body)
        raise "Can't create. #{res.inspect}" unless res["created"]
        obj._id = res["_id"].as_s
      end
      obj
    end

    macro inherited
      @@document_index : String?
      @@document_type : String?

      def self.document_type
        @@document_type ||= {{@type.stringify.underscore}}.gsub(/_repository$/, "")
      end

      def self.path
        "/#{document_index}/#{document_type}"
      end

      def self.path(part)
        "/#{document_index}/#{document_type}/#{part}"
      end

      def self.path(part : Nil)
        "/#{document_index}/#{document_type}"
      end

      def self.path(*parts)
        path(parts.join("/"))
      end
    end
  end
end
