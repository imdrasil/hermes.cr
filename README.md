# Hermes [![Build Status](https://travis-ci.org/imdrasil/hermes.cr.svg?branch=master)](https://travis-ci.org/imdrasil/hermes.cr)

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

- updates configurations of all indexes

```shell
$ crystal sam.cr -- es:index:update_all
```

- creates all indexes

```shell
$ crystal sam.cr -- es:index:create_all
```

- updates configuration of provided index

```shell
$ crystal sam.cr -- es:index:update index_name
```

- creates given index

```shell
$ crystal sam.cr -- es:index:create index_name
```

- destroy given index

```shell
$ crystal sam.cr -- es:index:destroy index_name
```

- destroy all indexes

```shell
$ crystal sam.cr -- es:index:destroy_all
```

### Index

First of all specify all your indexes. Here is example of some test index:

```crystal
class TestIndex < Hermes::Index
  index_name "test_index"

  config({
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
          likes:      {type: "integer"},
          user:       {:type => "text"},
          text:       {:type => "text"},
          tag:        {:type => "keyword"},
          created_at: {:type => "date"},
        },
      },

      user: {
        properties: {
          full_name: {type: "text"},
          location:  {type: "geo_point"},
          photo:     {type: "binary"},
        },
      },
    },
  })
end
```

> You could use both `NamedTuple` and hash notation

`config` macros allows you specify configs for index (settings, mappings, etc.). Here regular Elasticsearch options should be used.

Also using `index_name` method custom index name could be stored. By default underscored class name without last "_index" part is taken.

### Repository

Hermes implements some kind of Datamapper pattern so all CRUD and search logic will be inside of repository which allows to separate search and domain logic. So regular repository looks like this:

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

  es_fields(
    title: String,
    likes: {type: Int32, default: 0},
    user: String,
    text: String,
    tag: {type: String, nilable: true},
    created_at: Time | Nil,
    non_existing_field: {type: Int32 | Nil, nilable: true}
  )
end
```

`es_fields` macros works almost same way as `JSON.mapping` except generating several extra methods:

- `#{{attribute_name}}!` - for all given attributes with getters; makes not nil assertion
- `#initialize(Hash(String, Any))`
- `#initialize(Hash(Symbol, Any))`
- `#initialize(**)`
- `#assign_es_fields(Hash)` - will set all given fields
- `#assign_es_fields(**)`
- `#to_hash` - returns hash with all attributes (keys are strings)

#### Data types

All regular Crystal data types, which could be mapped from Elasticsearch data types, are supported (like `Int32`, `String` or `Times`, or `Array(Int32)`). Also supported all "special" data types:

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
PostRepository.create({"user" => "kim", "message" => "some message", "tag" => "es", "time" => Time.local })

PostRepository.create(user: "eddy", message: "some message", tag: "es", time: Time.local )

obj = Post.new({"user" => "kim", "message" => "some message", "tag" => "es", "time" => Time.local })
PostRepository.save(obj)
```

Due to Elasticsearch documentations, new object will be indexed in several seconds. So to do it immediatly you can manualy refresh:

```crystal
TestIndex.refresh
# or passing true as second parameter for #save

PostRepository.save(obj, true)
```

Such usage could slow down everything.

#### Read

Single document can be retrieved by it's id:

```crystal
PostRepository.find("elastic_uid_here") # object or nil
PostRepository.find!("elastic_uid_here") # object or exception
PostRepository.multi_get(["uid1", "uid2"]) # array of found objects by their ids
PostRepository.all
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
PostRepository.update("some_id", { script: {...}}) # allow specify entire request body

PostRepository.update_doc("some_id", {user: "tomas"}) # accepts "doc" part of body

PostRepository.update_by_script("some_id", {
  script: {
    inline: "ctx._source.likes += params.count",
    lang:   "painless",
    params: {count: 1},
  },
}) # allow specify entire request body
```

and `_update_by_query`

```crystal
PostRepository.update_by_query({
  script: {
    inline: "ctx._source.likes += params.count",
    lang:   "painless",
    params: {count: 1},
  },
  query: {
    term: {
      user: "kim",
    },
  },
})
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

Hermes uses one connection and is needed to be tested with multi-threading (check safety).

## Development

There are still a lot of work to do. Tasks for next versions:

- [ ] fully cover with tests
- [ ] add IP related logic to `Hermes::Types::IP` and move it to separate shard (like [ruby-ip](https://github.com/deploy2/ruby-ip))
- [ ] think about adding smth like [connection pool](https://github.com/ysbaddaden/pool)
- [ ] add [Jennifer](https://github.com/imdrasil/jennifer.cr) support
- [ ] add more things below...

## Contributing

1. [Fork it](https://github.com/imdrasil/hermes.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

Please ask me before start any work on some feature.

Also if you want to use it in your application - ping me please, my email could be found in my profile.

To run test use regular `crystal spec`.

## Contributors

- [imdrasil](https://github.com/imdrasil) Roman Kalnytskyi - creator, maintainer
