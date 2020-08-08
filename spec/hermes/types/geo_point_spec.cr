require "../../spec_helper"

describe Hermes::Types::GeoPoint do
  describe "constructor" do
    it "accepts raw arguments" do
      p = Hermes::Types::GeoPoint.new(1.0, 2.0)
      p.lat.should eq(1.0)
      p.lon.should eq(2.0)
    end
  end

  # context "as field of object" do
  #   it "properly deserialized" do
  #     obj = UserRepository.create(
  #       full_name: "some name",
  #       photo: Hermes::Types::Binary.new("asd"),
  #       location: Hermes::Types::GeoPoint.new(1.0, 2.0),
  #     )
  #     TestIndex.refresh
  #     obj = UserRepository.find!(obj._id)
  #     obj.location.lat.should eq(1.0)
  #     obj.location.lon.should eq(2.0)
  #   end
  # end
end
