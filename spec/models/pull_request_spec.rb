require "spec_helper"
require "app/models/pull_request"
require "app/models/commit"
require "app/models/pull_request_file"
require "lib/github_api"

describe PullRequest do
  let(:token) { "some_github_token" }

  describe "#opened?" do
    context "when payload action is opened" do
      it "returns true" do
        pull_request = PullRequest.new(payload_stub(action: "opened"), token)

        expect(pull_request).to be_opened
      end
    end

    context "when payload action is not opened" do
      it "returns false" do
        payload = payload_stub(action: "notopened")
        pull_request = PullRequest.new(payload, token)

        expect(pull_request).not_to be_opened
      end
    end
  end

  describe "#synchronize?" do
    context "when payload action is synchronize" do
      it "returns true" do
        payload = payload_stub(action: "synchronize")
        pull_request = PullRequest.new(payload, token)

        expect(pull_request).to be_synchronize
      end
    end

    context "when payload action is not synchronize" do
      it "returns false" do
        payload = payload_stub(action: "notsynchronize")
        pull_request = PullRequest.new(payload, token)

        expect(pull_request).not_to be_synchronize
      end
    end
  end

  describe "#comments" do
    it "returns comments on pull request" do
      filename = "spec/models/style_guide_spec.rb"
      comment = double(:comment, position: 7, path: filename)
      github = double(:github, pull_request_comments: [comment])
      pull_request = pull_request_stub(github)

      comments = pull_request.comments

      expect(comments.size).to eq(1)
      expect(comments).to match_array([comment])
    end
  end

  describe "#pull_request_files" do
    context "when files are added" do
      it "returns commit files" do
        file_contents = double("FileContents", content: "some content")
        github_file = double(
          "GitHubFile",
          status: "added",
          filename: "test.rb",
          patch: ""
        )
        removed_github_file = double(
          "GitHubFile",
          status: "removed",
          filename: "test.rb",
          patch: ""
        )
        github = double(
          "GitHub",
          pull_request_files: [github_file, removed_github_file],
          file_contents: file_contents
        )
        pull_request = pull_request_stub(github)

        expect(pull_request.pull_request_files.count).to eq(1)
      end
    end

    context "when file are removed" do
      it "returns empty" do
        file_contents = double("FileContents", content: "some content")
        github_file = double(
          "GitHubFile",
          status: "removed",
          filename: "test.rb",
          patch: ""
        )
        github = double(
          "GitHub",
          pull_request_files: [github_file],
          file_contents: file_contents
        )
        pull_request = pull_request_stub(github)

        expect(pull_request.pull_request_files.count).to eq(0)
      end
    end
  end

  describe "#comment_on_violation" do
    it "posts a comment to GitHub for the Hound user" do
      payload = payload_stub
      github = double(:github_client, add_pull_request_comment: nil)
      pull_request = pull_request_stub(github, payload)
      violation = violation_stub
      commit = double("Commit")
      allow(Commit).to receive(:new).and_return(commit)

      pull_request.comment_on_violation(violation)

      expect(github).to have_received(:add_pull_request_comment).with(
        pull_request_number: payload.pull_request_number,
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

  def payload_stub(options = {})
    defaults = {
      full_repo_name: "org/repo",
      head_sha: "1234abcd",
      pull_request_number: 5,
    }
    double("Payload", defaults.merge(options))
  end

  def pull_request_stub(api, payload = payload_stub)
    allow(GithubApi).to receive(:new).and_return(api)
    PullRequest.new(payload, token)
  end
end
