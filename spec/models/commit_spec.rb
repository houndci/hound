require "fast_spec_helper"
require "attr_extras"
require "octokit"
require "app/models/commit"

describe Commit do
  describe "#file_content" do
    context "when content is returned from GitHub" do
      it "returns content" do
        file_contents = double(content: Base64.encode64("some content"))
        github = double(:github_api, file_contents: file_contents)
        commit = Commit.new("test/test", "abc", github)

        expect(commit.file_content("test.rb")).to eq "some content"
      end
    end

    context "when file contains special characters" do
      it "does not error when linters try writing to disk" do
        text = "€25.00"
        file_contents = double(content: Base64.encode64(text))
        github = double("GithubApi", file_contents: file_contents)
        commit = Commit.new("test/test", "abc", github)
        tmp_file = Tempfile.new("foo", encoding: "utf-8")

        expect { tmp_file.write(commit.file_content("test.rb")) }.
          not_to raise_error
      end
    end

    context "when nothing is returned from GitHub" do
      it "returns blank string" do
        github = double(:github_api, file_contents: nil)
        commit = Commit.new("test/test", "abc", github)

        expect(commit.file_content("test.rb")).to eq ""
      end
    end

    context "when content is nil" do
      it "returns blank string" do
        contents = double(:contents, content: nil)
        github = double(:github_api, file_contents: contents)
        commit = Commit.new("test/test", "abc", github)

        expect(commit.file_content("test.rb")).to eq ""
      end
    end

    context "when error occurs when fetching from GitHub" do
      it "returns blank string" do
        github = double(:github_api)
        commit = Commit.new("test/test", "abc", github)
        allow(github).to receive(:file_contents).and_raise(Octokit::NotFound)

        expect(commit.file_content("test.rb")).to eq ""
      end
    end
  end
end
