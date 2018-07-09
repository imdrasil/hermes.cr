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
      hash.should eq({
        "title" => post.title,
        "likes" => post.likes,
        "user" => post.user,
        "text" => post.text,
        "tag" => post.tag,
        "created_at" => post.created_at,
        "non_existing_field" => nil
      })
    end
  end

  describe "#to_json" do
    it "generates json" do
      post = build_post
      hash = post.to_json
      hash.should eq({
        "title" => post.title,
        "likes" => post.likes,
        "user" => post.user,
        "text" => post.text,
        "tag" => post.tag,
        "created_at" => post.created_at,
    }.to_json)
    end
  end
end
