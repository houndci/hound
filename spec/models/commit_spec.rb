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

  describe "#comments" do
    it "returns comments on pull request" do
      filename = "spec/models/style_guide_spec.rb"
      comment = double(:comment, position: 7, path: filename)
      github = double(:github, pull_request_comments: [comment])
      commit = Commit.new("test/test", "abc", github, pull_request_number: 1)

      comments = commit.comments

      expect(comments.size).to eq(1)
      expect(comments).to match_array([comment])
    end
  end

  describe "#add_comment" do
    it "posts a comment to GitHub for the Hound user" do
      github = double(:github_client, add_comment: nil)
      violation = violation_stub
      commit = Commit.new("test/test", "abc", github, pull_request_number: 1)
      allow(Commit).to receive(:new).and_return(commit)

      commit.add_comment(violation)

      expect(github).to have_received(:add_comment).with(
        pull_request_number: 1,
        commit: commit,
        comment: violation.messages.first,
        filename: violation.filename,
        patch_position: violation.patch_position,
      )
    end
  end

  def violation_stub(options = {})
    defaults =  {
      messages: ["A comment"],
      filename: "test.rb",
      patch_position: 123,
    }
    double("Violation", defaults.merge(options))
  end
end
