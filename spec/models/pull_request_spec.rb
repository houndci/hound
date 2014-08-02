require "spec_helper"

describe PullRequest do
  describe "#opened?" do
    context "when payload action is opened" do
      it "returns true" do
        payload = double(:payload, action: "opened")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).to be_opened
      end
    end

    context "when payload action is not opened" do
      it "returns false" do
        payload = double(:payload, action: "notopened")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).not_to be_opened
      end
    end
  end

  describe "#synchronize?" do
    context "when payload action is synchronize" do
      it "returns true" do
        payload = double(:payload, action: "synchronize")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).to be_synchronize
      end
    end

    context "when payload action is not synchronize" do
      it "returns false" do
        payload = double(:payload, action: "notsynchronize")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).not_to be_synchronize
      end
    end
  end

  describe "#comments" do
    it "returns comments on pull request" do
      payload = double(
        :payload,
        full_repo_name: "org/repo",
        number: 4,
        head_sha: "abc123"
      )
      patch_position = 7
      filename = "spec/models/style_guide_spec.rb"
      comment = double(:comment, position: patch_position, path: filename)
      github = double(:github, pull_request_comments: [comment])
      allow(GithubApi).to receive(:new).and_return(github)
      pull_request = PullRequest.new(payload, "githubtoken")

      comments = pull_request.comments

      expect(comments.size).to eq(1)
      expect(comments).to match_array([comment])
    end
  end

  describe "#add_comment" do
    it "posts a comment to GitHub for the Hound user" do
      payload = double(
        :payload,
        full_repo_name: "org/repo",
        number: "123",
        head_sha: "1234abcd"
      )
      commit = double(:commit, repo_name: payload.full_repo_name)
      github = double(:github_client, add_comment: nil)
      allow(GithubApi).to receive(:new).and_return(github)
      allow(Commit).to receive(:new).and_return(commit)
      violation = double(
        :violation,
        messages: ["A comment"],
        filename: "test.rb",
        line: double(:line, patch_position: 123)
      )
      pull_request = PullRequest.new(payload, "gh-token")

      pull_request.add_comment(violation)

      expect(github).to have_received(:add_comment).with(
        pull_request_number: payload.number,
        commit: commit,
        comment: "A comment",
        filename: "test.rb",
        patch_position: 123
      )
    end
  end

  def pull_request(api)
    payload = double(
      :payload,
      number: 1,
      full_repo_name: "org/repo",
      head_sha: "abc123"
    )
    allow(GithubApi).to receive(:new).and_return(api)
    PullRequest.new(payload, "gh-token")
  end
end
