module Hermes
  class Config
    {% for field in [:host, :port, :schema] %}
      @@{{field.id}} = nil

      def self.{{field.id}}=(value)
        @@{{field.id}} = value
      end

      def self.{{field.id}}
        @@{{field.id}}
      end
    {% end %}

    @@host = "localhost"
    @@port = 9200
    @@schema = "http"

    def self.configure
      yield self
    end
  end
end
