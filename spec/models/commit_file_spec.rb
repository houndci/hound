require "fast_spec_helper"
require "base64"
require "app/models/commit_file"
require "app/models/patch"
require "active_support/core_ext/hash"

describe CommitFile do
  describe "#relevant_line?" do
    context "when line is modified" do
      it "returns true" do
        modified_line = double(:modified_line, line_number: 1)
        patch = double(:patch, additions: [modified_line])
        Patch.stub(new: patch)

        result = commit_file.relevant_line?(1)

        expect(result).to be_true
      end
    end

    context "when line is not modified" do
      it "returns false" do
        modified_line = double(:modified_line, line_number: 1)
        patch = double(:patch, additions: [modified_line])
        Patch.stub(new: patch)

        result = commit_file.relevant_line?(2)

        expect(result).to be_false
      end
    end
  end

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

  describe "#ruby?" do
    context "when file is non-ruby" do
      it "returns false for json" do
        commit_file1 = commit_file(filename: "app/models/user.json")
        commit_file2 = commit_file(filename: "public/main.css.scss")

        expect(commit_file1).not_to be_ruby
        expect(commit_file2).not_to be_ruby
      end
    end

    context "when file language is ruby" do
      it "returns true" do
        commit_file = commit_file(filename: "app/models/user.rb")

        expect(commit_file).to be_ruby
      end
    end
  end

  describe "#modified_line_at" do
    context "with a modified line" do
      it "returns modified line at the given line number" do
        modified_line = double(:modified_line, line_number: 1)
        patch = double(:patch, additions: [modified_line])
        Patch.stub(new: patch)

        expect(commit_file.modified_line_at(1)).to eq modified_line
      end
    end

    context "without a modified line" do
      it "returns nil" do
        modified_line = double(:modified_line, line_number: 1)
        patch = double(:patch, additions: [modified_line])
        Patch.stub(new: patch)

        expect(commit_file.modified_line_at(2)).to be_nil
      end
    end
  end

  describe "#content" do
    it "returns string content" do
      commit_file = commit_file(status: "modified")

      expect(commit_file.content).to eq "some content"
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
