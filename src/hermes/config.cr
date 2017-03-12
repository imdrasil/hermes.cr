module Hermes
  class Config
    {% for field in [:host, :port, :schema, :default_index] %}
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
    @@default_index : String?

    def self.configure
      yield self
    end
  end
end
