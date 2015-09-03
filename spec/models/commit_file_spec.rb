require "base64"

require "spec_helper"
require "app/models/commit_file"
require "app/models/patch"
require "app/models/unchanged_line"

describe CommitFile do
  describe "#line_at" do
    context "with a changed line" do
      it "returns a line at the given line number" do
        line = double("Line", number: 1)
        patch = double("Patch", changed_lines: [line])
        allow(Patch).to receive(:new).and_return(patch)

        expect(commit_file.line_at(1)).to eq line
      end
    end

    context "without a changed line" do
      it "returns nil" do
        line = double("Line", number: 1)
        patch = double("Patch", changed_lines: [line])
        allow(Patch).to receive(:new).and_return(patch)

        expect(commit_file.line_at(2)).to be_an UnchangedLine
      end
    end
  end

  describe "#filename" do
    it "returns filename" do
      expect(commit_file.filename).to eq "test.rb"
    end
  end

  describe "#content" do
    it "returns content" do
      expect(commit_file.content).to eq "content"
    end
  end

  describe "#patch" do
    it "returns patch" do
      expect(commit_file.patch).to eq "patch"
    end
  end

  def commit_file(options = {})
    commit = double("Commit", file_content: "content")
    CommitFile.new(filename: "test.rb", patch: "patch", commit: commit)
  end
end
