require "attr_extras"
require "fast_spec_helper"
require "app/models/style_guide/base"
require "app/models/style_guide/unsupported"

describe StyleGuide::Unsupported do
  describe "#violations_in_file" do
    it "returns an empty array" do
      style_guide = StyleGuide::Unsupported.new({}, nil)

      expect(style_guide.violations_in_file("file.txt")).to eq []
    end
  end
end
