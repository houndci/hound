require "fast_spec_helper"
require "attr_extras"
require "lib/github_api"
require "json"
require "app/models/github_user"

describe GithubApi do
  describe "#repos" do
    it "fetches all repos from Github" do
      token = "something"
      api = GithubApi.new(token)
      stub_repo_requests(token)

      repos = api.repos

      expect(repos.size).to eq 4
    end
  end

  describe "#create_hook" do
    context "when hook does not exist" do
      it "creates pull request web hook" do
        full_repo_name = "jimtom/repo"
        callback_endpoint = "http://example.com"
        token = "something"
        api = GithubApi.new(token)
        request = stub_hook_creation_request(
          full_repo_name,
          callback_endpoint,
          token
        )

        api.create_hook(full_repo_name, callback_endpoint)

        expect(request).to have_been_requested
      end

      it "yields hook" do
        full_repo_name = "jimtom/repo"
        callback_endpoint = "http://example.com"
        token = "something"
        api = GithubApi.new(token)
        request = stub_hook_creation_request(
          full_repo_name,
          callback_endpoint,
          token
        )
        yielded = false

        api.create_hook(full_repo_name, callback_endpoint) do |hook|
          yielded = true
        end

        expect(request).to have_been_requested
        expect(yielded).to be_truthy
      end
    end

    context "when hook already exists" do
      it "does not raise" do
        full_repo_name = "jimtom/repo"
        callback_endpoint = "http://example.com"
        stub_failed_hook_creation_request(full_repo_name, callback_endpoint)
        api = GithubApi.new

        expect do
          api.create_hook(full_repo_name, callback_endpoint)
        end.not_to raise_error
      end

      it "returns true" do
        full_repo_name = "jimtom/repo"
        callback_endpoint = "http://example.com"
        stub_failed_hook_creation_request(full_repo_name, callback_endpoint)
        api = GithubApi.new

        expect(api.create_hook(full_repo_name, callback_endpoint)).to eq true
      end
    end
  end

  describe "#remove_hook" do
    it "removes pull request web hook" do
      repo_name = "test-user/repo"
      hook_id = "123"
      stub_hook_removal_request(repo_name, hook_id)
      api = GithubApi.new

      response = api.remove_hook(repo_name, hook_id)

      expect(response).to be_truthy
    end

    it "yields given block" do
      repo_name = "test-user/repo"
      hook_id = "123"
      stub_hook_removal_request(repo_name, hook_id)
      api = GithubApi.new
      yielded = false

      api.remove_hook(repo_name, hook_id) do
        yielded = true
      end

      expect(yielded).to eq true
    end
  end

  describe "#pull_request_files" do
    it "returns changed files in a pull request" do
      api = GithubApi.new
      pull_request = double(:pull_request, full_repo_name: "thoughtbot/hound")
      pr_number = 123
      commit_sha = "abc123"
      stub_pull_request_files_request(pull_request.full_repo_name, pr_number)
      stub_contents_request(
        repo_name: pull_request.full_repo_name,
        sha: commit_sha
      )

      files = api.pull_request_files(pull_request.full_repo_name, pr_number)

      expect(files.size).to eq(1)
      expect(files.first.filename).to eq "config/unicorn.rb"
    end
  end

  describe "#add_pull_request_comment" do
    it "adds comment to GitHub pull request" do
      api = GithubApi.new("authtoken")
      repo_name = "test/repo"
      pull_request_number = 2
      comment = "test comment"
      commit_sha = "commitsha"
      file = "test.rb"
      patch_position = 123
      commit = double(:commit, repo_name: repo_name, sha: commit_sha)
      request = stub_comment_request(
        repo_name,
        pull_request_number,
        comment,
        commit_sha,
        file,
        patch_position
      )

      api.add_pull_request_comment(
        pull_request_number: pull_request_number,
        commit: commit,
        comment: "test comment",
        filename: file,
        patch_position: patch_position
      )

      expect(request).to have_been_requested
    end

    describe "#pull_request_comments" do
      it "returns comments added to pull request" do
        api = GithubApi.new
        pull_request = double(:pull_request, full_repo_name: "thoughtbot/hound")
        pull_request_id = 253
        commit_sha = "abc253"
        expected_comment = "inline if's and while's are not violations?"
        stub_pull_request_comments_request(
          pull_request.full_repo_name,
          pull_request_id
        )
        stub_contents_request(
          repo_name: pull_request.full_repo_name,
          sha: commit_sha
        )

        comments = api.pull_request_comments(
          pull_request.full_repo_name,
          pull_request_id
        )

        expect(comments.size).to eq(4)
        expect(comments.first.body).to eq expected_comment
      end
    end

    describe "#accept_pending_invitations" do
      it "finds and accepts pending org invitations" do
        api = GithubApi.new
        memberships_request = stub_memberships_request
        membership_update_request = stub_membership_update_request

        api.accept_pending_invitations

        expect(memberships_request).to have_been_requested
        expect(membership_update_request).to have_been_requested
      end
    end

    it "returns user's teams" do
      teams = ["thoughtbot"]
      client = double(user_teams: teams)
      allow(Octokit::Client).to receive(:new).and_return(client)
      api = GithubApi.new

      user_teams = api.user_teams

      expect(user_teams).to eq teams
    end
  end

  describe "#create_pending_status" do
    it "makes request to GitHub for creating a pending status" do
      api = GithubApi.new
      request = stub_status_request(
        "test/repo",
        "sha",
        "pending",
        "description"
      )

      api.create_pending_status("test/repo", "sha", "description")

      expect(request).to have_been_requested
    end

    describe "when setting the status returns 404" do
      it "does not crash" do
        sha = "abc"
        api = GithubApi.new
        repo_name = "test/repo"
        stub_failed_status_creation_request(
          repo_name,
          sha,
          "pending",
          "description"
        )

        expect do
          api.create_pending_status(repo_name, sha, "description")
        end.not_to raise_error
      end
    end
  end

  describe "#create_success_status" do
    it "makes request to GitHub for creating a success status" do
      api = GithubApi.new
      request = stub_status_request(
        "test/repo",
        "sha",
        "success",
        "description"
      )

      api.create_success_status("test/repo", "sha", "description")

      expect(request).to have_been_requested
    end
  end

  describe "#add_user_to_team" do
    it "makes a request to GitHub" do
      token = "some_token"
      username = "houndci"
      team_id = 123
      api = GithubApi.new(token)
      request = stub_add_user_to_team_request(username, team_id, token)

      api.add_user_to_team(username, team_id)

      expect(request).to have_been_requested
    end
  end

  describe "#add_repo_to_team" do
    it "makes a request to GitHub" do
      token = "some_token"
      repo_name = "foo/bar"
      team_id = 123
      api = GithubApi.new(token)
      request = stub_add_repo_to_team_request(repo_name, team_id, token)

      api.add_repo_to_team(team_id, repo_name)

      expect(request).to have_been_requested
    end
  end

  describe "#create_team" do
    it "makes a request to GitHub" do
      token = "some_token"
      org_name = "foo"
      repo_name = "foo/bar"
      team_name = "TestTeam"
      api = GithubApi.new(token)
      request = stub_create_team_request(org_name, team_name, repo_name, token)

      api.create_team(
        org_name: org_name,
        team_name: team_name,
        repo_name: repo_name
      )

      expect(request).to have_been_requested
    end
  end

  describe "#add_collaborator" do
    it "makes a request to GitHub" do
      username = "houndci"
      repo_name = "foo/bar"
      token = "github_token"
      api = GithubApi.new(token)
      request = stub_add_collaborator_request(username, repo_name, token)

      api.add_collaborator(repo_name, username)

      expect(request).to have_been_requested
    end
  end

  describe "#update_team" do
    it "makes a request" do
      team_id = 123
      api = GithubApi.new
      request = stub_update_team_permission_request(team_id)

      api.update_team(team_id, permissions: "push")

      expect(request).to have_been_requested
    end
  end
end
