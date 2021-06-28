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

class User
  include Hermes::Persistent

  es_fields(
    full_name: String,
    location: Hermes::Types::GeoPoint,
    photo: Hermes::Types::Binary
  )
end

class Shape
  include Hermes::Persistent

  es_fields(
    name: String,
    ip: Hermes::Types::IP,
    area: Hermes::Types::Circle
  )
end

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
    },
  })
end

class TestUserIndex < Hermes::Index
  index_name "test_user_index"
  config({
    user: {
      properties: {
        full_name: {type: "text"},
        location:  {type: "geo_point"},
        photo:     {type: "binary"},
      },
    },
  })
end

class AnotherIndex < Hermes::Index
  index_name("another_test_index")
  config({
    :mappings => {
      :shape => {
        :properties => {
          :name => {:type => "text"},
          :ip   => {:type => "ip"},
          :area => {:type => "geo_shape"},
        },
      },
    },
  })
end

class PostRepository < Hermes::Repository(TestIndex, Post)
  document_type "posts"
end

class UserRepository < Hermes::Repository(TestUserIndex, User)
end

class ShapeRepository < Hermes::Repository(AnotherIndex, Shape)
end
