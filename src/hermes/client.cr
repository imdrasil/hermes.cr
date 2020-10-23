module Hermes
  class Client
    property http

    def initialize
      @headers = HTTP::Headers.new
      @headers.add("Accept", "application/json")
      @headers.add("Content-Type", "application/json")

      @http = HTTP::Client.new(URI.new(Config.schema, Config.host, Config.port))
    end

    {% for method in [:get, :post, :put, :delete, :head] %}
      def {{method.id}}(url, headers = nil, body = nil)
        res = @http.{{method.id}}(url, @headers, body)
        Response.new(res)
      end
    {% end %}

    {% for method in [:get, :post, :put, :delete] %}
      def {{method.id}}!(url, headers = nil, body = nil)
        res = @http.{{method.id}}(url, @headers, body)
        if res.status_code < 300
          Response.new(res)
        else
          raise res.inspect
        end
      end
    {% end %}
  end
end
