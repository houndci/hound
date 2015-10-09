require "rails_helper"

describe Linter::Unsupported do
  describe ".can_lint?" do
    it "returns true" do
      result = Linter::Unsupported.can_lint?(double)

      expect(result).to eq true
    end
  end

  describe "#file_review" do
    it "raises" do
      linter = Linter::Unsupported.new(
        hound_config: double,
        build: double,
        repository_owner_name: "foo",
      )
      commit_file = double("CommitFile", filename: "unsupported.f95")

      expect do
        linter.file_review(commit_file)
      end.to raise_error(Linter::Unsupported::CannotReviewUnsupportedFile)
    end
  end

  describe "#file_included?" do
    it "return false" do
      linter = Linter::Unsupported.new(
        hound_config: double,
        build: double,
        repository_owner_name: "foo",
      )

      expect(linter.file_included?(double)).to eq false
    end
  end
end
