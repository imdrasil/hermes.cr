require "../spec_helper"

describe Hermes::Persistent do
  describe "#assign_es_fields" do
    it "assigns fields by given hash" do
      post = build_post
      post.assign_es_fields(likes: 1, user: "tom")
      post.likes.should eq(1)
      post.user.should eq("tom")
      post.assign_es_fields({"likes" => 2})
      post.likes.should eq(2)
    end
  end

  describe "#to_hash" do
    it "dumps all fields to hash" do
      post = build_post
      hash = post.to_hash
      hash["title"].should eq(post.title)
      hash["likes"].should eq(post.likes)
      hash["user"].should eq(post.user)
      hash["text"].should eq(post.text)
      hash["tag"].should eq(post.tag)
      hash["created_at"].should eq(post.created_at)
    end
  end
end
