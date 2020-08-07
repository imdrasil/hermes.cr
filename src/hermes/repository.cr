module Hermes
  class Repository(I, T)
    def self.document_index
      I.index_name
    end

    def self.index
      I
    end

    def self.document_type(name)
      @@document_type = name
    end

    def self.reload(obj)
      raise "Not implemented yet"
    end

    def self.update(id, hash)
      Hermes.client.post(path(id, "_update"), nil, hash.to_json)
    end

    def self.update_doc(id, hash)
      update(id, {doc: hash})
    end

    def self.update_by_script(id, hash)
      update(id, {script: hash})
    end

    def self.update_by_query(hash)
      Hermes.client.post(path("_update_by_query"), nil, hash.to_json)
    end

    def self.search(hash)
      res = Hermes.client.get(path("_search"), nil, hash.to_json)
      SearchResponse(T).from_json(res.body)
    end

    def self.multi_get(ids)
      res = Hermes.client.get(path("_mget"), nil, {ids: ids}.to_json)
      MultiGetResponse(T).from_json(res.body).entries
    end

    def self.all
      res = Hermes.client.get(path("_search"), nil, %({"query": {"match_all":{}}}))
      SearchResponse(T).from_json(res.body)
    end

    def self.aggregate(aggs, query = {match_all: {} of String => String})
      res = Hermes.client.get(path("_search"), nil, {size: 0, query: query, aggs: aggs}.to_json)
      AggregationResponse.from_json(res.body)
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
      res = Hermes.client.get!(path(id))
      Hit(T).from_json(res.body)._source
    end

    def self.delete(id)
      Hermes.client.delete(path(id))
    end

    def self.delete!(id)
      Hermes.client.delete!(path(id))
    end

    def self.delete_by_query(hash)
      Hermes.client.post(path("_delete_by_query"), nil, hash.to_json)
    end

    def self.create(hash)
      save(T.new(hash))
    end

    def self.create(**opts)
      save(T.new(**opts))
    end

    def self.count(hash)
      res = Hermes.client.get!(path("_count"), nil, hash.to_json)
      res.json["count"].as_i
    end

    def self.save(obj : Persistent, refresh = false)
      body = obj.to_json
      unless obj.es_new_record?
        Hermes.client.put(path(obj._id, refresh), nil, body)
      else
        res = Hermes.client.post(path(refresh), nil, body)
        # NOT WORK
        # raise "Can't create. #{res.inspect}" unless res["created"]
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

      def self.path(part, refresh : Bool)
        if refresh
          path(part) + "?refresh"
        else
          path(part)
        end
      end

      def self.path(refresh : Bool)
        if refresh
          path + "?refresh"
        else
          path
        end
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
