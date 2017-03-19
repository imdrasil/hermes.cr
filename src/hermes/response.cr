module Hermes
  class Response
    getter raw : HTTP::Client::Response

    def initialize(@raw)
    end

    def [](key : String)
      json[key]
    end

    def []?(key : String)
      json[key]?
    end

    def body
      @raw.body
    end

    def json
      @json ||= JSON.parse(@raw.body)
    end

    def status
      @raw.status_code
    end
  end
end
