module Hermes
  module Persistent
    property _id = "", _index = "", _type = ""

    macro definition(properties, strict = false)
      {% for key, value in properties %}
        {% properties[key] = {type: value} unless value.is_a?(HashLiteral) || value.is_a?(NamedTupleLiteral) %}
      {% end %}

      {% for key, value in properties %}
        @{{key.id}} : {{value[:type]}} {{ (value[:nilable] ? "?" : "").id }}

        {% if value[:setter] == nil ? true : value[:setter] %}
          def {{key.id}}=(_{{key.id}} : {{value[:type]}} {{ (value[:nilable] ? "?" : "").id }})
            @{{key.id}} = _{{key.id}}
          end
        {% end %}

        {% if value[:getter] == nil ? true : value[:getter] %}
          def {{key.id}}
            @{{key.id}}
          end
        {% end %}
      {% end %}

      def initialize(hash)
        {% for key, value in properties %}
          {% unless value[:nilable] || value[:default] != nil %}
            if !hash.has_key?("{{key.id}}") && !Union({{value[:type]}}).nilable?
              raise "missing hash attribute: {{(value[:key] || key).id}}"
            end
          {% end %}
        {% end %}

        {% for key, value in properties %}
          {% if value[:nilable] %}
            {% if value[:default] != nil %}
              @{{key.id}} = hash.has_key?("{{key.id}}") ? hash["{{key.id}}"] : {{value[:default]}}
            {% else %}
              @{{key.id}} = hash["{{key.id}}"]?
            {% end %}
          {% elsif value[:default] != nil %}
            @{{key.id}} = !hash.has_key?("{{key.id}}") ? {{value[:default]}} : hash["{{key.id}}"]
          {% else %}
            @{{key.id}} = (hash["{{key.id}}"]?).as({{value[:type]}})
          {% end %}
        {% end %}
      end

      def initialize(%pull : JSON::PullParser)
        {% for key, value in properties %}
          %var{key.id} = nil
          %found{key.id} = false
        {% end %}

        %pull.read_object do |key|
          case key
          {% for key, value in properties %}
            when {{value[:key] || key.id.stringify}}
              %found{key.id} = true

              %var{key.id} =
                {% if value[:nilable] || value[:default] != nil %} %pull.read_null_or { {% end %}

                {% if value[:root] %}
                  %pull.on_key!({{value[:root]}}) do
                {% end %}

                {% if value[:converter] %}
                  {{value[:converter]}}.from_json(%pull)
                {% elsif value[:type].is_a?(Path) || value[:type].is_a?(Generic) %}
                  {{value[:type]}}.new(%pull)
                {% else %}
                  Union({{value[:type]}}).new(%pull)
                {% end %}

                {% if value[:root] %}
                  end
                {% end %}

              {% if value[:nilable] || value[:default] != nil %} } {% end %}

          {% end %}
          else
            {% if strict %}
              raise JSON::ParseException.new("unknown json attribute: #{key}", 0, 0)
            {% else %}
              %pull.skip
            {% end %}
          end
        end

        {% for key, value in properties %}
          {% unless value[:nilable] || value[:default] != nil %}
            if %var{key.id}.is_a?(Nil) && !%found{key.id} && !Union({{value[:type]}}).nilable?
              raise JSON::ParseException.new("missing json attribute: {{(value[:key] || key).id}}", 0, 0)
            end
          {% end %}
        {% end %}

        {% for key, value in properties %}
          {% if value[:nilable] %}
            {% if value[:default] != nil %}
              @{{key.id}} = %found{key.id} ? %var{key.id} : {{value[:default]}}
            {% else %}
              @{{key.id}} = %var{key.id}
            {% end %}
          {% elsif value[:default] != nil %}
            @{{key.id}} = %var{key.id}.is_a?(Nil) ? {{value[:default]}} : %var{key.id}
          {% else %}
            @{{key.id}} = (%var{key.id}).as({{value[:type]}})
          {% end %}
        {% end %}
      end

      def to_hash
        {
          {% for key, value in properties %}
            {{key.stringify}} => @{{key.id}},
          {% end %}
        }
      end

      def to_json(json : ::JSON::Builder)
        json.object do
        {% for key, value in properties %}
          _{{key.id}} = @{{key.id}}

          {% unless value[:emit_null] %}
            unless _{{key.id}}.nil?
          {% end %}

            json.field({{value[:key] || key.id.stringify}}) do
              {% if value[:root] %}
                {% if value[:emit_null] %}
                  if _{{key.id}}.nil?
                    nil.to_json(json)
                  else
                {% end %}

                json.object do
                  json.field({{value[:root]}}) do
              {% end %}

              {% if value[:converter] %}
                if _{{key.id}}
                  {{ value[:converter] }}.to_json(_{{key.id}}, json)
                else
                  nil.to_json(json)
                end
              {% else %}
                _{{key.id}}.to_json(json)
              {% end %}

              {% if value[:root] %}
                {% if value[:emit_null] %}
                  end
                {% end %}
                  end
                end
              {% end %}
            end

          {% unless value[:emit_null] %}
            end
          {% end %}
        {% end %}
      end
    end
  end

    # This is a convenience method to allow invoking `JSON.mapping`
    # with named arguments instead of with a hash/named-tuple literal.
    macro definition(**properties)
      definition({{properties}})
    end
  end
end
