module Hermes
  class Response
    def initialize(@raw : HTTP::Client::Response)
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
