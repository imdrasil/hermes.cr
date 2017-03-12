require "spec"
require "../src/hermes"

Hermes::Config.configure do |c|
  # c.default_index = "test_index"
end

class Post
  include Hermes::Persistent

  definition(
    user: String,
    message: String,
    tag: {type: String, nilable: true},
    time: Time | Nil,
    tsim: {type: Int32 | Nil, nilable: true}
  )
end

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

class PostRepository < Hermes::Repository(TestIndex, Post)
end
