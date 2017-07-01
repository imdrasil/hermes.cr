module Hermes
  module Persistent
    alias Any = String | Symbol | Time | Float32 | Float64 | Int32 | Int16 | ::Hermes::Types::Binary | ::Hermes::Types::IP | Hermes::Types::GeoPoint | Hermes::Types::IGeoShape | Hermes::Types::GeometryCollection | Hash(String | Symbol, Any)
    property _id = "", _index = "", _type = ""

    def es_new_record?
      _id.empty?
    end

    macro included
      extend ::Hermes::Persistent::Macrosses
    end

    module Macrosses
      macro es_fields(properties, strict = false, prefix = "")
        {% for key, value in properties %}
          {% properties[key] = {type: value} unless value.is_a?(HashLiteral) || value.is_a?(NamedTupleLiteral) %}
          {% properties[key][:name] = "#{prefix.id}#{key.id}" %}
        {% end %}

        {% for key, value in properties %}
          @{{value[:name].id}} : {{value[:type]}} {{ (value[:nilable] ? "?" : "").id }}

          {% if value[:setter] == nil ? true : value[:setter] %}
            def {{value[:name].id}}=(_{{key.id}} : {{value[:type]}} {{ (value[:nilable] ? "?" : "").id }})
              @{{value[:name].id}} = _{{key.id}}
            end
          {% end %}

          {% if value[:getter] == nil ? true : value[:getter] %}
            def {{value[:name].id}}!
              @{{value[:name].id}}.not_nil!
            end

            def {{value[:name].id}}
              @{{value[:name].id}}
            end
          {% end %}
        {% end %}

        def initialize(_hash : Hash(String, Any))
          hash = Hermes.deep_hash_converting(_hash)
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
                @{{value[:name].id}} = hash.has_key?("{{key.id}}") ? hash["{{key.id}}"].as({{value[:type]}}) : {{value[:default]}}
              {% else %}
                @{{value[:name].id}} = hash["{{key.id}}"]?.as({{value[:type]}})
              {% end %}
            {% elsif value[:default] != nil %}
              @{{value[:name].id}} = !hash.has_key?("{{key.id}}") ? {{value[:default]}} : hash["{{key.id}}"].as({{value[:type]}})
            {% else %}
              @{{value[:name].id}} = (hash["{{key.id}}"]?).as({{value[:type]}})
            {% end %}
          {% end %}
        end

        def initialize(_hash : Hash(Symbol, Any))
          hash = Hermes.deep_hash_converting(_hash)
          {% for key, value in properties %}
            {% unless value[:nilable] || value[:default] != nil %}
              if !hash.has_key?(:{{key.id}}) && !Union({{value[:type]}}).nilable?
                raise "missing hash attribute: {{(value[:key] || key).id}}"
              end
            {% end %}
          {% end %}

          {% for key, value in properties %}
            {% if value[:nilable] %}
              {% if value[:default] != nil %}
                @{{value[:name].id}} = hash.has_key?(:{{key.id}}) ? hash[:{{key.id}}].as({{value[:type]}}) : {{value[:default]}}
              {% else %}
                @{{value[:name].id}} = hash[:{{key.id}}]?.as({{value[:type]}})
              {% end %}
            {% elsif value[:default] != nil %}
              @{{value[:name].id}} = !hash.has_key?(:{{key.id}}) ? {{value[:default]}} : hash[:{{key.id}}].as({{value[:type]}})
            {% else %}
              @{{value[:name].id}} = (hash[:{{key.id}}]?).as({{value[:type]}})
            {% end %}
          {% end %}
        end

        def initialize(**hash)
          {% for key, value in properties %}
            {% unless value[:nilable] || value[:default] != nil %}
              if !hash.has_key?(:{{key.id}}) && !Union({{value[:type]}}).nilable?
                raise "missing hash attribute: {{(value[:key] || key).id}}"
              end
            {% end %}
          {% end %}

          {% for key, value in properties %}
            {% if value[:nilable] %}
              {% if value[:default] != nil %}
                @{{value[:name].id}} = hash.has_key?(:{{key.id}}) ? hash[:{{key.id}}].as({{value[:type]}}) : {{value[:default]}}
              {% else %}
                @{{value[:name].id}} = hash[:{{key.id}}]?.as({{value[:type]}})
              {% end %}
            {% elsif value[:default] != nil %}
              @{{value[:name].id}} = !hash.has_key?(:{{key.id}}) ? {{value[:default]}} : hash[:{{key.id}}].as({{value[:type]}})
            {% else %}
              @{{value[:name].id}} = (hash[:{{key.id}}]?).as({{value[:type]}})
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
                @{{value[:name].id}} = %found{key.id} ? %var{key.id} : {{value[:default]}}
              {% else %}
                @{{value[:name].id}} = %var{key.id}
              {% end %}
            {% elsif value[:default] != nil %}
              @{{value[:name].id}} = %var{key.id}.is_a?(Nil) ? {{value[:default]}} : %var{key.id}
            {% else %}
              @{{value[:name].id}} = (%var{key.id}).as({{value[:type]}})
            {% end %}
          {% end %}
        end

        def assign_es_fields(_hash : Hash)
          hash = Hermes.deep_hash_converting(_hash)
          {% for key, value in properties %}
            if hash.has_key?("{{key.id}}")
              @{{value[:name].id}} = hash["{{key.id}}"].as({{value[:type]}})
            end
          {% end %}
        end

        def assign_es_fields(**opts)
          hash = Hermes.deep_hash_converting(opts)
          {% for key, value in properties %}
            if hash.has_key?(:{{key.id}})
              @{{value[:name].id}} = hash[:{{key.id}}].as({{value[:type]}})
            end
          {% end %}
        end

        def to_hash
          {
            {% for key, value in properties %}
              {{key.stringify}} => @{{value[:name].id}},
            {% end %}
          }
        end

        def to_json(json : ::JSON::Builder)
          json.object do
            {% for key, value in properties %}
              _{{key.id}} = @{{value[:name].id}}

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
      macro es_fields(**properties)
        es_fields({{properties}})
      end
    end
  end
end
