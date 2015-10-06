require 'test_helper'

describe "Crack::Util.to_xml_attributes" do
  before do
    @hash = { :one => "ONE", "two" => "TWO", :three => "it \"should\" work" }
  end

  it "turn the hash into xml attributes" do
    attrs = Crack::Util.to_xml_attributes(@hash)
    attrs.must_match /one="ONE"/m
    attrs.must_match /two="TWO"/m
    attrs.must_match /three="it &quot;should&quot; work"/m
  end

  it "preserve _ in hash keys" do
    attrs = Crack::Util.to_xml_attributes({
      :some_long_attribute => "with short value",
      :crash               => :burn,
      :merb                => "uses extlib"
    })

    attrs.must_match /some_long_attribute="with short value"/
    attrs.must_match /merb="uses extlib"/
    attrs.must_match /crash="burn"/
  end
end
