require "./spec_helper"

describe Hermes do
  describe "::bulk" do
    it "loads all to es" do
      r = Hermes.bulk([
        {index: {_index: "test_index", _type: "posts"}},
        {
          title:      "test t3",
          likes:      0,
          tag:        "wow",
          user:       "kim",
          text:       "tralala",
          created_at: Time.now,
        },
        {index: {_index: "test_index", _type: "posts"}},
        {
          title:      "test2",
          likes:      0,
          tag:        "wow",
          user:       "eddy",
          text:       "tralala",
          created_at: Time.now,
        },
      ])
      TestIndex.refresh
      PostRepository.all.entries.size.should eq(2)
    end
  end
end
