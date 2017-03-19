require "../../spec_helper"

describe Hermes::Types::Range do
  describe "constructor" do
    it "accepts pure arguments" do
      r = Hermes::Types::Range(Int32).new(2, 3)
      r.lte.should eq(2)
      r.gte.should eq(3)
    end
  end
end
