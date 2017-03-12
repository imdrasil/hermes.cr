# Hermes

This is an integration of Crystal and Elasticsearch via HTTP/HTTPS protocol.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  hermes:
    github: imdrasil/hermes.cr
```

## Usage

### Configuration

Put
```crystal
require "hermes"
```

in places where you load your configurations. For now you need to specify all configurations using dsl but in future support of yaml configuration files for different environments will be added. So this is regular configuration for playground environment:

```crystal
Hermes::Config.configure do |conf|
  conf.host = "localhost"
  conf.port = 9200
end
```

Default values:

| attribute | value |
| --- | --- |
| `host` | `"localhost"` |
| `port`| `9200` |
| `adapter` | `"mysql"` |
| `schema` | `"http"` |

### Command management

For command management Hermes uses [Sam](https://github.com/imdrasil/sam.cr). So in your `sam.cr` just add loading migrations and Jennifer hooks.

```crystal
require "./your_configuration_folder/*"
load_dependencies "./", "hermes"
# your another tasks here
Sam.help
```

#### Commands
Now you can use next commands:

- put all mappings to Elasticsearch
```shell
$ crystal sam.cr -- es:mapping:update
```

### Index

First of all specify all your indexes. Here is example of some test index:

```crystal
class TestIndex < Hermes::Index
  index_name("test_index")
  mapping({
    mappings: {
      post: {
        properties: {
          title: {
            type:   "text",
            fields: {
              raw: {
                type: "keyword",
              },
            },
          },
          user:     {type: "text"},
          message:  {type: "text"},
          tag:      {type: "keyword"},
          time:     {type: "date"},
          location: {type: "geo_point"},
        },
      },
    },
  })
end
```

`mapping` macros allowa you specify mappings for all document types. Here regular Elasticsearch options should be used. 

Also using `index_name` methods special index name could be stored. By default underscored class name without last "_index" part is taken.

### Repository

Hermes implements some kind of Datamapper pattern so all CRUD and search logic will be loated inside of repository which allows to separate search logic and domain logic. So regular repository looks like this:

```crystal
class PostRepository < Hermes::Repository(TestIndex, Post)
end
```

By default repository name is underscored class name without last "_repository" part. But it can be specified using `document_type` method.

### Persistent

This is module which includes mapping rules for fields. This allows to mix it into any class. Here is simple example:

```crystal
class Post
  include Hermes::Persistent

  definition(
    user: String,
    message: String,
    tag: {type: String, nilable: true},
    time: Time | Nil,
    some_unexisting_field: {type: Int32 | Nil, nilable: true}
  )
end
```

`definition` macros works almost same way as `JSON.mapping` except generating constructor accepting Hash with String keys and `to_hash` method, which returns hash with all atributes from mapping.

#### Data types

All regular Crystal data types, which could be mapped from Elasticsearch data types, are supportd (like `Int32`, `String` or `Times`, or `Array(Int32)`). Also supported all "special" data types:

- binary (`Hermes::Types::Binary`)
- range (`Hermes::Types::Range(T)`)

 > Due to Elasticsearch documentation there are several supported data types: `Int32`, `Int64`, `Float32` `Float64`, `Time`.
 
- IP address (`Hermes::Types::IP`)
- geometrical
  - geo_point (`Hermes::Types::GeoPoint`)
  - circle (`Hermes::Types::Circle`)
  - envelope (`Hermes::Types::Envelop`)
  - geometry collection (`Hermes::Types::GeometryCollection`)
  - line string (`Hermes::Types::LineString`)
  - multi line string (`Hermes::Types::MultiLineString`)
  - multi point (`Hermes::Types::MultiPoint`)
  - multi polygon (`Hermes::Types::MultiPolygon`)
  - point (`Hermes::Types::Point`)
  - polygon (`Hermes::Types::Polygon`)

### CRUD

#### Create

New object can be created from Hash (with string keys), NamedTuple or new Persistent object.

```crystal
PostRepository.create({"user" => "kim", "message" => "some message", "tag" => "es", "time" => Time.now })

obj = Post.new({"user" => "kim", "message" => "some message", "tag" => "es", "time" => Time.now })
PostRepository.save(obj)
```

Due to Elasticsearch documentations, new object will be indexed in several seconds. So to do it immediatly you can manualy refresh:

```crystal
PostRepository.refresh
```

#### Read

Single document can be retrieved by it's id:

```crystal
PostRepository.find("elastic_uid_here")
```

Also regular Elasticsearch query dsl could be used:

```crystal
PostRepository.search({
    query: {
        bool: {
            must: {
                term: {user: "kim"},
            },
            should: [
                {term: {tag: "wow"}},
                {term: {tag: "es"}},
            ],
            minimum_should_match: 1,
            boost:                1.0,
        },
    },
})
```

It will return `SearchResponse(T)` object (in this case `T` is a `Post`). It provide access to all response data and has shortcuts for search and aggregation results (`entries` and `aggs` methods).

If you need only count of matched objects:
```crystal
PostRepository.count({
    query: {
        bool: {
            must: {
                term: {user: "kim"},
            },
            should: [
                {term: {tag: "wow"}},
                {term: {tag: "es"}},
            ],
            minimum_should_match: 1,
            boost:                1.0,
        },
    },
}) # some Int32 value
```

Also there is shortcut for aggregations:

```crystal
PostRepository.aggregate({max_date: {max: {field: "time"}}})
```

It will return object of `SearchResponse(T)` as well as `search` but without entries inside.

#### Update

If you want to save new version of object, use regular same:

```crystal
obj.message = "another message"
PostRepository.save(obj)
```

Also there is method for `_update` Elasticsearch endpoint:

```crystal
PostRepository.update("some_id", { script: {...}})
```

and `_update_by_query`
```crystal
PostRepository.update_by_query({ script: {...}, query: { term: { user: "kim } })
```

#### Delete

To delete object by it's id use: 
```crystal
PostRepository.delete(obj._id)
```

Also you can do it using query:

```crystal
PostRepository.delete_by_query({query: {match: {message: "some message"}}})
```
## Restrictions

Now there is no tests (will be added in next release) so it hardly recomended not to use it for production usage. Also Hermes uses one connection and need to be tested with multithreading (check safety).

## Development

There are still a lot of work to do. Tasks for next versions:

- [ ] cover with tests
- [ ] add IP related logic to `Hermes::Types::IP` and move it to separate shard (like [ruby-ip](https://github.com/deploy2/ruby-ip))
- [ ] think about adding smth like [connection pool](https://github.com/ysbaddaden/pool)
- [ ] add [Jennifer](https://github.com/imdrasil/jennifer.cr) support
- [ ] add more thinks below...

## Contributing

1. [Fork it](https://github.com/imdrasil/hermes.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

Please ask me before start any work on some feature.

Also if you want to use it in your application - ping me please, my email you can find in my profile.

To run test use regular `crystal spec`.

## Contributors

- [imdrasil](https://github.com/imdrasil) Roman Kalnytskyi - creator, maintainer
