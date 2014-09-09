require "fast_spec_helper"
require "app/models/style_guide/unsupported"

describe StyleGuide::Unsupported do
  describe "#violations" do
    it "returns an empty array" do
      style_guide = StyleGuide::Unsupported.new

      expect(style_guide.violations("file.txt")).to eq []
    end
  end
end
