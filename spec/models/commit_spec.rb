require "fast_spec_helper"
require "attr_extras"
require "octokit"
require "app/models/commit"

describe Commit do
  describe "#file_content" do
    context "when content is returned from GitHub" do
      it "returns content" do
        commit = build_commit("some content")

        expect(commit.file_content("test.rb")).to eq "some content"
      end
    end

    context "when file contains special characters" do
      it "does not error when linters try writing to disk" do
        commit = build_commit("€25.00")
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

    context "when file too large error is raised" do
      it "returns blank" do
        github = double(:github_api)
        commit = Commit.new("test/test", "abc", github)
        error = Octokit::Forbidden.new(body: { errors: [code: "too_large"] })
        allow(github).to receive(:file_contents).and_raise(error)

        expect(commit.file_content("some/file.rb")).to eq ""
      end
    end

    context "when exception contains no errors" do
      it "raises the error" do
        github = double("GithubApi")
        commit = Commit.new("test/test", "abc", github)
        error = Octokit::Forbidden.new(body: { errors: [] })
        allow(github).to receive(:file_contents).and_raise(error)

        expect { commit.file_content("some/file.rb") }.to raise_error(error)
      end
    end
  end

  def build_commit(content)
    file_contents = double(content: Base64.encode64(content))
    github = double(:github_api, file_contents: file_contents)
    Commit.new("test/test", "abc", github)
  end
end
