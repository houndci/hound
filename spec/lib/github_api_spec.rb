require "fast_spec_helper"
require "attr_extras"
require "lib/github_api"
require "json"
require "app/models/github_user"

describe GithubApi do
  describe "#add_user_to_repo" do
    let(:token) { "abc123" }
    let(:username) { "testuser" }
    let(:organization) { "testing" }
    let(:repo_name) { "#{organization}/repo" }
    let(:team_id) { 4567 }
    let(:api) { GithubApi.new(token) }

    context "when repo is part of an organization" do
      context "when repo is part of a team" do
        context "when request succeeds" do
          it "adds Hound user to first repo team with admin access and return true" do
            stub_common_requests
            add_user_request =
              stub_add_user_to_team_request(username, team_id, token)

            expect(api.add_user_to_repo(username, repo_name)).to be_truthy
            expect(add_user_request).to have_been_requested
          end
        end

        context "when request fails" do
          it "tries to add Hound user to first repo team with admin access and returns false" do
            stub_common_requests
            add_user_request =
              stub_failed_add_user_to_team_request(username, team_id, token)

            expect(api.add_user_to_repo(username, repo_name)).to be_falsy
            expect(add_user_request).to have_been_requested
          end
        end

        def stub_common_requests
          stub_repo_with_org_request(repo_name, token)
          stub_repo_teams_request(repo_name, token)
          stub_user_teams_request(token)
        end
      end

      context "when repo is not part of a team" do
        context "when Services team does not exist" do
          it "creates a Services team and adds user to the new team" do
            team_id = 1234 # from fixture
            stub_repo_with_org_request(repo_name, token)
            stub_empty_repo_teams_request(repo_name, token)
            stub_team_creation_request(organization, repo_name, token)
            stub_org_teams_request(organization, token)
            add_user_request =
              stub_add_user_to_team_request(username, team_id, token)

            expect(api.add_user_to_repo(username, repo_name)).to be_truthy
            expect(add_user_request).to have_been_requested
          end
        end

        context "when team creation raises a validation error" do
          it "adds user to Services team" do
            stub_repo_with_org_request(repo_name, token)
            stub_empty_repo_teams_request(repo_name, token)
            stub_chained_org_teams_request(organization, token)
            stub_failed_team_creation_request(organization, repo_name, token)
            add_user_request =
              stub_add_user_to_team_request(username, team_id, token)

            api.add_user_to_repo(username, repo_name)

            expect(add_user_request).to have_been_requested
          end
        end

        context "when Services team exists" do
          context "when Services team is not on the first page of results" do
            it "adds user to Services team" do
              stub_repo_with_org_request(repo_name, token)
              stub_empty_repo_teams_request(repo_name, token)
              stub_paginated_org_teams_request(organization, token)
              add_repo_request =
                stub_add_repo_to_team_request(repo_name, team_id, token)
              add_user_request =
                stub_add_user_to_team_request(username, team_id, token)

              api.add_user_to_repo(username, repo_name)

              expect(add_user_request).to have_been_requested
              expect(add_repo_request).to have_been_requested
            end
          end

          it "adds user to Services team" do
            stub_repo_with_org_request(repo_name, token)
            stub_empty_repo_teams_request(repo_name, token)
            stub_org_teams_with_services_request(organization, token)
            add_repo_request =
              stub_add_repo_to_team_request(repo_name, team_id, token)
            add_user_request =
              stub_add_user_to_team_request(username, team_id, token)

            api.add_user_to_repo(username, repo_name)

            expect(add_user_request).to have_been_requested
            expect(add_repo_request).to have_been_requested
          end
        end
      end
    end

    context "when repo is not part of an organization" do
      it "adds user as collaborator" do
        stub_repo_request(repo_name, token)
        add_user_request =
          stub_add_user_to_repo_request(username, repo_name, token)

        expect(api.add_user_to_repo(username, repo_name)).to be_truthy
        expect(add_user_request).to have_been_requested
      end
    end
  end

  describe "#repos" do
    it "fetches all repos from Github" do
      auth_token = "authtoken"
      api = GithubApi.new(auth_token)
      stub_repo_requests(auth_token)

      repos = api.repos

      expect(repos.size).to eq 4
    end
  end

  describe "#create_hook" do
    context "when hook does not exist" do
      it "creates pull request web hook" do
        full_repo_name = "jimtom/repo"
        callback_endpoint = "http://example.com"
        request = stub_hook_creation_request(full_repo_name, callback_endpoint)
        api = GithubApi.new(AuthenticationHelper::GITHUB_TOKEN)

        api.create_hook(full_repo_name, callback_endpoint)

        expect(request).to have_been_requested
      end

      it "yields hook" do
        full_repo_name = "jimtom/repo"
        callback_endpoint = "http://example.com"
        request = stub_hook_creation_request(full_repo_name, callback_endpoint)
        api = GithubApi.new(AuthenticationHelper::GITHUB_TOKEN)
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
        api = GithubApi.new(AuthenticationHelper::GITHUB_TOKEN)

        expect do
          api.create_hook(full_repo_name, callback_endpoint)
        end.not_to raise_error
      end

      it "returns true" do
        full_repo_name = "jimtom/repo"
        callback_endpoint = "http://example.com"
        stub_failed_hook_creation_request(full_repo_name, callback_endpoint)
        api = GithubApi.new(AuthenticationHelper::GITHUB_TOKEN)

        expect(api.create_hook(full_repo_name, callback_endpoint)).
          to eq true
      end
    end
  end

  describe "#remove_hook" do
    it "removes pull request web hook" do
      repo_name = "test-user/repo"
      hook_id = "123"
      stub_hook_removal_request(repo_name, hook_id)
      api = GithubApi.new("sometoken")

      response = api.remove_hook(repo_name, hook_id)

      expect(response).to be_truthy
    end

    it "yields given block" do
      repo_name = "test-user/repo"
      hook_id = "123"
      stub_hook_removal_request(repo_name, hook_id)
      api = GithubApi.new("sometoken")
      yielded = false

      api.remove_hook(repo_name, hook_id) do
        yielded = true
      end

      expect(yielded).to eq true
    end
  end

  describe "#pull_request_files" do
    it "returns changed files in a pull request" do
      api = GithubApi.new("authtoken")
      pull_request = double(:pull_request, full_repo_name: "thoughtbot/hound")
      pull_request_number = 123
      commit_sha = "abc123"
      github_token = "authtoken"
      stub_pull_request_files_request(
        pull_request.full_repo_name,
        pull_request_number,
        github_token
      )
      stub_contents_request(
        github_token,
        repo_name: pull_request.full_repo_name,
        sha: commit_sha
      )

      files = api.pull_request_files(
        pull_request.full_repo_name,
        pull_request_number
      )

      expect(files.size).to eq(1)
      expect(files.first.filename).to eq "config/unicorn.rb"
    end
  end
end

describe GithubApi, "#add_comment" do
  it "adds comment to GitHub" do
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

    api.add_comment(
      pull_request_number: pull_request_number,
      commit: commit,
      comment: "test comment",
      filename: file,
      patch_position: patch_position
    )

    expect(request).to have_been_requested
  end
end

describe GithubApi do
  describe "#pull_request_comments" do
    it "returns comments added to pull request" do
      github_token = "authtoken"
      api = GithubApi.new(github_token)
      pull_request = double(:pull_request, full_repo_name: "thoughtbot/hound")
      pull_request_id = 253
      commit_sha = "abc253"
      expected_comment = "inline if's and while's are not violations?"
      stub_pull_request_comments_request(
        pull_request.full_repo_name,
        pull_request_id,
        github_token
      )
      stub_contents_request(
        github_token,
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
      github_token = "githubtoken"
      memberships_request = stubbed_memberships_request(github_token)
      membership_update_request = stubbed_membership_update_request(github_token)
      api = GithubApi.new(github_token)

      api.accept_pending_invitations

      expect(memberships_request).to have_been_requested
      expect(membership_update_request).to have_been_requested
    end
  end
end

describe GithubApi, "#user_teams" do
  it "returns user's teams" do
    token = "abc123"
    teams = ["thoughtbot"]
    client = double(user_teams: teams)
    allow(Octokit::Client).to receive(:new).and_return(client)
    api = GithubApi.new(token)

    user_teams = api.user_teams

    expect(user_teams).to eq teams
  end
end
