require "rails_helper"

describe CommitStatus do
  describe "#set_pending" do
    it "sets the pending status on GithubApi" do
      github_api = stubbed_github_api(:create_pending_status)
      repo_name = "houndci/hound"
      sha = "abc123"
      token = "token"
      commit_status = CommitStatus.new(
        repo_name: repo_name,
        sha: sha,
        token: token,
      )

      commit_status.set_pending

      expect(github_api).to have_received(:create_pending_status).with(
        repo_name,
        sha,
        I18n.t(:pending_status),
      )
    end
  end

  describe "#set_success" do
    it "sets the create success status on GithubApi" do
      github_api = stubbed_github_api(:create_success_status)
      repo_name = "houndci/hound"
      sha = "abc123"
      token = "token"
      violation_count = 5
      commit_status = CommitStatus.new(
        repo_name: repo_name,
        sha: sha,
        token: token,
      )

      commit_status.set_success(violation_count)

      expect(github_api).to have_received(:create_success_status).with(
        repo_name,
        sha,
        I18n.t(:complete_status, count: violation_count),
      )
    end
  end

  describe "#set_failure" do
    it "sets the error status for GithubApi" do
      github_api = stubbed_github_api(:create_error_status)
      repo_name = "houndci/hound"
      sha = "abc123"
      token = "token"
      violation_count = 5
      commit_status = CommitStatus.new(
        repo_name: repo_name,
        sha: sha,
        token: token,
      )

      commit_status.set_failure(violation_count)

      expect(github_api).to have_received(:create_error_status).with(
        repo_name,
        sha,
        I18n.t(:complete_status, count: violation_count),
      )
    end
  end

  describe "#set_config_error" do
    it "sets the error status for GithubApi" do
      github_api = stubbed_github_api(:create_error_status)
      repo_name = "houndci/hound"
      sha = "abc123"
      token = "token"
      message = "invalid config"
      commit_status = CommitStatus.new(
        repo_name: repo_name,
        sha: sha,
        token: token,
      )

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
    it "sets the error status for GithubApi" do
      github_api = stubbed_github_api(:create_error_status)
      repo_name = "houndci/hound"
      sha = "abc123"
      token = "token"
      commit_status = CommitStatus.new(
        repo_name: repo_name,
        sha: sha,
        token: token,
      )

      commit_status.set_internal_error

      expect(github_api).to have_received(:create_error_status).with(
        repo_name,
        sha,
        I18n.t(:hound_error_status),
      )
    end
  end

  def stubbed_github_api(*methods)
    github_api = double("GithubApi")
    allow(GithubApi).to receive(:new).and_return(github_api)

    methods.each do |method_name|
      allow(github_api).to receive(method_name)
    end

    github_api
  end

  def configuration_url
    Rails.application.routes.url_helpers.configuration_url(host: Hound::HOST)
  end
end
