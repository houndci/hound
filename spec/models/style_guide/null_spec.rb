require "fast_spec_helper"
require "app/models/style_guide/null"

describe StyleGuide::Null, "#violations" do
  it "returns an empty array" do
    style_guide = StyleGuide::Null.new("{}")

    expect(style_guide.violations("file.txt")).to eq []
  end
end
