require "rails_helper"

RSpec.describe CommitStatus do
  describe "#set_pending" do
    it "sets the pending status on GitHubApi" do
      github_api = stubbed_github_api(:create_pending_status)
      sha = "abc123"
      repo = instance_double("Repo", name: "houndci/hound")
      github_auth = instance_double("GitHubAuth", token: "token")
      commit_status = CommitStatus.new(
        repo: repo,
        sha: sha,
        github_auth: github_auth,
      )

      commit_status.set_pending

      expect(github_api).to have_received(:create_pending_status).with(
        repo.name,
        sha,
        I18n.t(:pending_status),
      )
    end

    context "when status update fails" do
      it "removes the user from repo and notifies Sentry" do
        sha = "abc123"
        user = create(:user, token: "token")
        repo = create(:repo, name: "houndci/hound", users: [user])
        github_auth = GitHubAuth.new(repo)
        commit_status = CommitStatus.new(
          repo: repo,
          sha: sha,
          github_auth: github_auth,
        )
        github_api = instance_double("GitHubApi", repository?: true)
        allow(github_api).to receive(:create_pending_status).
          and_raise(Octokit::NotFound)
        allow(GitHubApi).to receive(:new).and_return(github_api)
        allow(Raven).to receive(:capture_message)

        expect { commit_status.set_pending }.to raise_error(Octokit::NotFound)

        expect(GitHubApi).to have_received(:new).with(user.token).twice
        expect(repo.reload.users).to eq []
        expect(Raven).to have_received(:capture_message).with(
          "Failed to set pending status",
          extra: {
            repo_name: repo.name,
            sha: sha,
          },
        )
      end
    end
  end

  describe "#set_success" do
    it "sets the create success status on GitHubApi" do
      github_api = stubbed_github_api(:create_success_status)
      sha = "abc123"
      violation_count = 5
      repo = instance_double("Repo", name: "houndci/hound")
      github_auth = instance_double("GitHubAuth", token: "token")
      commit_status = CommitStatus.new(
        repo: repo,
        sha: sha,
        github_auth: github_auth,
      )

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
      repo = instance_double("Repo", name: "houndci/hound")
      github_auth = instance_double("GitHubAuth", token: "token")
      sha = "abc123"
      violation_count = 5
      commit_status = CommitStatus.new(
        repo: repo,
        sha: sha,
        github_auth: github_auth,
      )

      commit_status.set_failure(violation_count)

      expect(github_api).to have_received(:create_error_status).with(
        repo.name,
        sha,
        I18n.t(:complete_status, count: violation_count),
        nil,
      )
    end

    context "when status update fails" do
      it "removes the user from repo and notifies Sentry" do
        user = create(:user, token: "token")
        repo = create(:repo, name: "houndci/hound", users: [user])
        github_auth = GitHubAuth.new(repo)
        sha = "abc123"
        commit_status = CommitStatus.new(
          repo: repo,
          sha: sha,
          github_auth: github_auth,
        )
        github_api = instance_double("GitHubApi", repository?: true)
        allow(GitHubApi).to receive(:new).and_return(github_api)
        allow(github_api).to receive(:create_error_status).
          and_raise(Octokit::NotFound)
        allow(Raven).to receive(:capture_message)

        expect { commit_status.set_failure(1) }.
          to raise_error(Octokit::NotFound)

        expect(Raven).to have_received(:capture_message).with(
          "Failed to set error status",
          extra: {
            repo_name: repo.name,
            sha: sha,
            message: "1 violation found.",
            url: nil,
          },
        )
      end
    end
  end

  describe "#set_config_error" do
    it "sets the error status for GitHubApi" do
      github_api = stubbed_github_api(:create_error_status)
      repo = instance_double("Repo", name: "houndci/hound")
      github_auth = instance_double("GitHubAuth", token: "token")
      sha = "abc123"
      message = "invalid config"
      commit_status = CommitStatus.new(
        repo: repo,
        sha: sha,
        github_auth: github_auth,
      )

      commit_status.set_config_error(message)

      expect(github_api).to have_received(:create_error_status).with(
        repo.name,
        sha,
        message,
        configuration_url,
      )
    end
  end

  describe "#set_internal_error" do
    it "sets the error status for GitHubApi" do
      github_api = stubbed_github_api(:create_error_status)
      repo = instance_double("Repo", name: "houndci/hound")
      github_auth = instance_double("GitHubAuth", token: "token")
      sha = "abc123"
      commit_status = CommitStatus.new(
        repo: repo,
        sha: sha,
        github_auth: github_auth,
      )

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
    ENV.fetch("DOCS_URL")
  end
end
