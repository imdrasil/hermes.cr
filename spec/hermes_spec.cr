require "./spec_helper"

describe Hermes do
  it "works" do
    # r = PostRepository.search({query: {bool: {must: [{match: {user: "kim"}}]}}})
    # puts r.entries

    # p = Post.new({"user" => "eddy", "message" => "try it, dude"})
    # PostRepository.save(p)
    # puts p._id
    # puts PostRepository.find(p._id).inspect
    puts PostRepository.count({"query" => {"match_all": {} of String => String}})
  end

  it "query" do
    # PostRepository.create({"user" => "kim", "message" => "new one", "tag" => "es"})
    body = {
      title:    "test t3",
      tag:      "wow",
      user:     "kim",
      message:  "tralala",
      time:     Time.now,
      location: {lat: 41.72, lon: -71.34},
    }
    # r = Hermes.client.post("/test_index/post", nil, body.to_json)

    body = {
      title:    "test t2",
      tag:      "wow",
      user:     "kim",
      message:  "tralala",
      time:     Time.now,
      location: "drm3btev3e86",
    }
    # PostRepository.refresh
    # r = Hermes.client.post("/test_index/post", nil, body.to_json)
    # puts r.json.inspect
    # puts r.json.inspect
    # r = PostRepository.search({
    #  query: {
    #    bool: {
    #      must: {
    #        term: {user: "kim"},
    #      },
    #      should: [
    #        {term: {tag: "wow"}},
    #        {term: {tag: "es"}},
    #      ],
    #      minimum_should_match: 1,
    #      boost:                1.0,
    #    },
    #  },
    # })
    r = PostRepository.search({query: {match_all: {} of String => String}})
    puts r.entries[0].inspect
    # r = PostRepository.search({size: 0, aggs: {max_date: {max: {field: "time"}}}})
    r = PostRepository.aggregate({max_date: {max: {field: "time"}}})
    puts r.inspect
    # puts r.json.inspect
  end

  it "index" do
    # puts TestIndex.mapping
  end
end
