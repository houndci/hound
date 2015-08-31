require "rails_helper"

describe StyleGuide::Unsupported do
  describe "#file_review" do
    it "raises" do
      style_guide = StyleGuide::Unsupported.new(
        repo_config: double,
        build: double,
        repository_owner_name: "foo",
      )
      commit_file = double("CommitFile", filename: "unsupported.f95")

      expect { style_guide.file_review(commit_file) }.to raise_error(
        StyleGuide::Unsupported::CannotReviewUnsupportedFile
      )
    end
  end

  describe "#file_included?" do
    it "return false" do
      style_guide = StyleGuide::Unsupported.new(
        repo_config: double,
        build: double,
        repository_owner_name: "foo",
      )

      expect(style_guide.file_included?(double)).to eq false
    end
  end
end
