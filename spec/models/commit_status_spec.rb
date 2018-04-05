require "rails_helper"

RSpec.describe CommitStatus do
  describe "#set_pending" do
    it "sets the pending status on GitHubApi" do
      github_api = stubbed_github_api(:create_pending_status)
      sha = "abc123"
      user = instance_double("User", token: "some-token")
      repo = instance_double("Repo", name: "houndci/hound")
      commit_status = CommitStatus.new(repo: repo, sha: sha, user: user)

      commit_status.set_pending

      expect(github_api).to have_received(:create_pending_status).with(
        repo.name,
        sha,
        I18n.t(:pending_status),
      )
    end
  end

  describe "#set_success" do
    it "sets the create success status on GitHubApi" do
      github_api = stubbed_github_api(:create_success_status)
      sha = "abc123"
      violation_count = 5
      user = instance_double("User", token: "some-token")
      repo = instance_double("Repo", name: "houndci/hound")
      commit_status = CommitStatus.new(repo: repo, sha: sha, user: user)

      commit_status.set_success(violation_count)

      expect(github_api).to have_received(:create_success_status).with(
        repo.name,
        sha,
        I18n.t(:complete_status, count: violation_count),
      )
    end
  end

  describe "#set_failure" do
    it "sets the error status for GitHubApi" do
      github_api = stubbed_github_api(:create_error_status)
      sha = "abc123"
      violation_count = 5
      user = instance_double("User", token: "some-token")
      repo = instance_double("Repo", name: "houndci/hound")
      commit_status = CommitStatus.new(repo: repo, sha: sha, user: user)

      commit_status.set_failure(violation_count)

      expect(github_api).to have_received(:create_error_status).with(
        repo.name,
        sha,
        I18n.t(:complete_status, count: violation_count),
        nil,
      )
    end
  end

  describe "#set_config_error" do
    it "sets the error status for GitHubApi" do
      github_api = stubbed_github_api(:create_error_status)
      repo_name = "houndci/hound"
      sha = "abc123"
      message = "invalid config"
      user = instance_double("User", token: "some-token")
      repo = instance_double("Repo", name: "houndci/hound")
      commit_status = CommitStatus.new(repo: repo, sha: sha, user: user)

      commit_status.set_config_error(message)

      expect(github_api).to have_received(:create_error_status).with(
        repo_name,
        sha,
        message,
        configuration_url,
      )
    end
  end

  describe "#set_internal_error" do
    it "sets the error status for GitHubApi" do
      github_api = stubbed_github_api(:create_error_status)
      sha = "abc123"
      user = instance_double("User", token: "some-token")
      repo = instance_double("Repo", name: "houndci/hound")
      commit_status = CommitStatus.new(repo: repo, sha: sha, user: user)

      commit_status.set_internal_error

      expect(github_api).to have_received(:create_error_status).with(
        repo.name,
        sha,
        I18n.t(:hound_error_status),
        nil,
      )
    end
  end

  def stubbed_github_api(*methods)
    github_api = double("GitHubApi")
    allow(GitHubApi).to receive(:new).and_return(github_api)

    methods.each do |method_name|
      allow(github_api).to receive(method_name)
    end

    github_api
  end

  def configuration_url
    Rails.application.routes.url_helpers.configuration_url(host: Hound::HOST)
  end
end
