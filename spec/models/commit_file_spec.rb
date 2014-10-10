require "base64"

require "fast_spec_helper"
require "app/models/commit_file"
require "app/models/patch"
require "app/models/unchanged_line"

describe CommitFile do
  describe "#removed?" do
    context "when status is removed" do
      it "returns true" do
        commit_file = commit_file(status: "removed")

        expect(commit_file).to be_removed
      end
    end

    context "when status is added" do
      it "returns false" do
        commit_file = commit_file(status: "added")

        expect(commit_file).not_to be_removed
      end
    end
  end

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

  describe "#content" do
    context "when file is removed" do
      it "returns nil" do
        commit_file = commit_file(status: "removed")

        expect(commit_file.content).to eq nil
      end
    end

    context "when file is modified" do
      it "returns content string" do
        commit_file = commit_file(status: "modified")

        expect(commit_file.content).to eq "some content"
      end
    end
  end

  def commit_file(options = {})
    file = double(:file, options.reverse_merge(patch: "", filename: "test.rb"))
    commit = double(
      :commit,
      repo_name: "test/test",
      sha: "abc",
      file_content: "some content"
    )
    CommitFile.new(file, commit)
  end
end
