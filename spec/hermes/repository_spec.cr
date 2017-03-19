require "../spec_helper"

describe Hermes::Repository do
  describe "::document_index" do
    it "returns index name" do
      PostRepository.document_index.should eq("test_index")
    end
  end

  describe "::document_type" do
    it "should return auto name if not specified" do
      UserRepository.document_type.should eq("user")
    end

    it "returns specified name" do
      PostRepository.document_type.should eq("posts")
    end
  end

  describe "::document_refresh" do
    pending "fill" do
    end
  end

  describe "::update_doc" do
    it "updates record by given id" do
      post = create_post
      PostRepository.update_doc(post._id, {title: "some uniq title"})
      TestIndex.refresh
      PostRepository.find!(post._id).title.should eq("some uniq title")
    end
  end

  describe "::update_by_script" do
    it "correctly updates by given argument using it as script" do
      post = create_post
      PostRepository.update_by_script(post._id, {
        inline: "ctx._source.likes += params.count",
        lang:   "painless",
        params: {count: 1},
      })
      PostRepository.find!(post._id).likes.should eq(1)
    end
  end

  describe "::update" do
    it "update given doc by given description" do
      post = create_post
      r = PostRepository.update(post._id, {
        script: {
          inline: "ctx._source.likes += params.count",
          lang:   "painless",
          params: {count: 1},
        },
      })
      PostRepository.find!(post._id).likes.should eq(1)
    end
  end

  describe "::update_by_query" do
    it "correctly updates by given argument using it as script" do
      post1 = create_post(user: "kim")
      post2 = create_post(user: "yao")
      TestIndex.refresh
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
      PostRepository.find!(post1._id).likes.should eq(1)
      PostRepository.find!(post2._id).likes.should eq(0)
    end
  end

  describe "::search" do
    it "correctly searches by given query" do
      p1 = PostRepository.save(build_post(tag: "search", user: "kim"), true)
      p2 = PostRepository.save(build_post(user: "kim", tag: "elastic"), true)
      PostRepository.save(build_post(user: "eddy", tag: "elastic"), true)
      r = PostRepository.search({
        query: {
          bool: {
            must: {
              term: {user: "kim"},
            },
            should: [
              {term: {tag: "search"}},
              {term: {tag: "elastic"}},
            ],
            minimum_should_match: 1,
            boost:                1.0,
          },
        },
      })
      r.entries.size.should eq(2)
    end
  end

  describe "::agregate" do
    it "correctly aggregates" do
      p1 = PostRepository.save(build_post(tag: "search", user: "kim", likes: 2), true)
      p2 = PostRepository.save(build_post(user: "kim", tag: "elastic", likes: 3), true)
      r = PostRepository.aggregate({total_likes: {sum: {field: "likes"}}})

      r.aggs["total_likes"]["value"].should eq(5)
    end
  end

  describe "::explain" do
  end

  describe "::find" do
    it "properly finds by given uid" do
      post1 = create_post(user: "kim")
      TestIndex.refresh
      PostRepository.find(post1._id).should_not be_nil
    end

    it "returns nil otherwise" do
      post1 = create_post(user: "kim")
      TestIndex.refresh
      PostRepository.find(post1._id + "a").should be_nil
    end
  end

  describe "::find!" do
    it "raises exception if there is no object with given id" do
      expect_raises(Exception) do
        PostRepository.find!("asd")
      end
    end
  end

  describe "::delete" do
    it "deletes object by given id" do
      post1 = create_post(user: "kim")
      TestIndex.refresh
      PostRepository.delete(post1._id)
      TestIndex.refresh
      PostRepository.find(post1._id).should be_nil
    end
  end

  describe "::delete_by_query" do
    it "deletes objects by given query" do
      post1 = create_post(user: "kim")
      post2 = create_post(user: "eddy")
      TestIndex.refresh
      PostRepository.delete_by_query({query: {term: {user: "kim"}}})
      TestIndex.refresh
      PostRepository.find(post1._id).should be_nil
      PostRepository.find(post2._id).should_not be_nil
    end
  end

  describe "::create" do
    it "creates object by given hash" do
      obj = PostRepository.create({:title => "t1", :user => "kim", :text => "test", :tag => "es", :created_at => Time.now})
      obj.should be_a(Post)
      obj._id.should_not be_nil
      TestIndex.refresh
      PostRepository.find(obj._id).should_not be_nil
    end
  end

  describe "::count" do
    it "counts objects by given query" do
      post1 = create_post(user: "kim")
      post2 = create_post(user: "eddy")
      TestIndex.refresh
      PostRepository.count({query: {term: {user: "kim"}}}).should eq(1)
    end
  end

  describe "::save" do
    it "saves existsing objects" do
      post1 = create_post(user: "kim")
      TestIndex.refresh
      post1.user = "eddy"
      PostRepository.save(post1, true)
      PostRepository.find!(post1._id).user!.should eq("eddy")
    end

    it "saves new object and assign new uid" do
      p = Post.new({:title => "t1", :user => "kim", :text => "test", :tag => "es", :created_at => Time.now})
      obj = PostRepository.save(p)
      p._id.should eq(obj._id)
      p._id.should_not be_nil
    end
  end

  describe "::multi_get" do
    it "returns array of retrieved objects" do
      post1 = create_post(user: "kim")
      post2 = create_post(user: "yao")
      post3 = create_post(user: "eddy")
      TestIndex.refresh
      res = PostRepository.multi_get([post1._id, post3._id])
      (res.map(&._id) & [post1._id, post3._id]).size.should eq(2)
    end
  end

  describe "::all" do
    it "retrieves all" do
      post1 = create_post(user: "kim")
      post2 = create_post(user: "yao")
      post3 = create_post(user: "eddy")
      TestIndex.refresh
      PostRepository.all.entries.size.should eq(3)
    end
  end
end
