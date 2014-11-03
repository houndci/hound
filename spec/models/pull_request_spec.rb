require "fast_spec_helper"
require "app/models/pull_request"
require "app/models/commit"
require "lib/github_api"

describe PullRequest do
  describe "#opened?" do
    context "when payload action is opened" do
      it "returns true" do
        pull_request = PullRequest.new(payload_stub(action: "opened"), "token")

        expect(pull_request).to be_opened
      end
    end

    context "when payload action is not opened" do
      it "returns false" do
        payload = payload_stub(action: "notopened")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).not_to be_opened
      end
    end
  end

  describe "#synchronize?" do
    context "when payload action is synchronize" do
      it "returns true" do
        payload = payload_stub(action: "synchronize")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).to be_synchronize
      end
    end

    context "when payload action is not synchronize" do
      it "returns false" do
        payload = payload_stub(action: "notsynchronize")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).not_to be_synchronize
      end
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
    allow(GithubApi).to receive(:new).and_return(api)
    PullRequest.new(payload, "github-token")
  end
end
