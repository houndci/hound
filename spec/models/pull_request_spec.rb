require "rails_helper"
require "app/models/pull_request"
require "app/models/commit"
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

  describe "#commit_files" do
    it "does not include removed files" do
      added_github_file = double(
        filename: "foo.rb",
        status: "added",
        patch: "patch"
      )
      modified_github_file = double(
        filename: "baz.rb",
        status: "modified",
        patch: "patch"
      )
      removed_github_file = double(
        filename: "bar.rb",
        status: "removed"
      )
      all_github_files = [
        added_github_file,
        removed_github_file,
        modified_github_file
      ]
      github = double(:github, pull_request_files: all_github_files)
      pull_request = pull_request_stub(github)
      commit = double("Commit", file_content: "content", sha: "abc123")
      allow(Commit).to receive(:new).and_return(commit)

      commit_files = pull_request.commit_files

      expect(commit_files.map(&:filename)).to match_array(
        [added_github_file.filename, modified_github_file.filename]
      )
    end
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
    allow(GitHubApi).to receive(:new).and_return(api)
    PullRequest.new(payload, token)
  end
end
