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
    it "fetches comments from GitHub" do
      github = double(:github_client, commit_comments: nil)
      commit = Commit.new("test/test", "abc", github)

      commit.comments

      expect(github).to have_received(:commit_comments).with(
        commit.repo_name,
        commit.sha
      )
    end
  end

  describe "#add_comment" do
    it "posts a comment to GitHub for the Hound user" do
      github = double(:github_client, add_commit_comment: nil)
      commit = Commit.new("test/test", "abc", github)
      comment = "Commit violation"

      commit.add_comment(comment)

      expect(github).to have_received(:add_commit_comment).with(
        commit: commit,
        comment: comment
      )
    end
  end

  describe "#subject" do
    context "with a commit message" do
      it "returns all lines up to double newlines" do
        commit = Commit.new(double, double, double).
          tap { |c| c.message = "fix\na\n\nbug" }

        expect(commit.subject).to eq("fix\na")
      end
    end

    context "with an empty commit message" do
      it "returns an empty string" do
        commit = Commit.new(double, double, double).
          tap { |c| c.message = "" }

        expect(commit.subject).to eq("")
      end
    end

    context "without a commit message" do
      it "returns an empty string" do
        commit = Commit.new(double, double, double)

        expect(commit.subject).to eq("")
      end
    end
  end

  describe "#body" do
    context "with a commit message" do
      it "returns all lines after the first double newlines" do
        commit = Commit.new(double, double, double).
          tap { |c| c.message = "fix\n\na\n\nbug" }

        expect(commit.body).to eq("a\n\nbug")
      end
    end

    context "with an empty commit message" do
      it "returns an empty string" do
        commit = Commit.new(double, double, double).
          tap { |c| c.message = "" }

        expect(commit.subject).to eq("")
      end
    end

    context "without a commit message" do
      it "returns an empty string" do
        commit = Commit.new(double, double, double)

        expect(commit.body).to eq("")
      end
    end
  end
end
