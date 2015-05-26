require "rails_helper"

describe StyleGuide::Unsupported do
  describe "#file_review" do
    it "returns file review without violations" do
      file = double("FakeFile", filename: "file.txt")
      style_guide = StyleGuide::Unsupported.new({}, nil)

      expect(style_guide.file_review(file).violations).to eq []
    end
  end
end
