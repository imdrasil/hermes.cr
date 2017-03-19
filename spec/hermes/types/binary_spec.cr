require "../../spec_helper"

describe Hermes::Types::Binary do
  describe "::encode" do
    it "creates new Binary" do
      b = Hermes::Types::Binary.encode("some string")
      b.should be_a(Hermes::Types::Binary)
      b.raw.should eq(Base64.encode("some string"))
    end
  end

  describe "#decode" do
    it "decodes data to byte array" do
      b = Hermes::Types::Binary.new(Base64.encode("some string"))
      b.decode.should eq(Bytes[115, 111, 109, 101, 32, 115, 116, 114, 105, 110, 103])
    end
  end

  describe "#decode_string" do
    it "decodes data to byte array" do
      b = Hermes::Types::Binary.new(Base64.encode("some string"))
      b.decode_string.should eq("some string")
    end
  end
end
