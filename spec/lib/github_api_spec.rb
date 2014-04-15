require 'fast_spec_helper'
require 'lib/github_api'
require 'json'
require 'app/models/github_user'

describe GithubApi do
  describe '#add_user_to_repo' do
    context 'when repo is part of an organization' do
      context 'when repo is part of a team' do
        context 'when request succeeds' do
          it 'adds Hound user to first repo team with admin access and return true' do
            token = 'abc123'
            username = 'testuser'
            repo_name = 'testing/repo' # from fixture
            team_id = 4567 # from fixture
            api = GithubApi.new(token)
            stub_repo_with_org_request(repo_name, token)
            stub_repo_teams_request(repo_name, token)
            stub_user_teams_request(token)
            add_user_request = stub_add_user_to_team_request(
              username,
              team_id,
              token
            )

            expect(api.add_user_to_repo(username, repo_name)).to be_true
            expect(add_user_request).to have_been_requested
          end
        end

        context 'when request fails' do
          it 'tries to add Hound user to first repo team with admin access and returns false' do
            token = 'abc123'
            username = 'testuser'
            repo_name = 'testing/repo' # from fixture
            team_id = 4567 # from fixture
            api = GithubApi.new(token)
            stub_repo_with_org_request(repo_name, token)
            stub_repo_teams_request(repo_name, token)
            stub_user_teams_request(token)
            add_user_request = stub_failed_add_user_to_team_request(
              username,
              team_id,
              token
            )

            expect(api.add_user_to_repo(username, repo_name)).to be_false
            expect(add_user_request).to have_been_requested
          end
        end
      end

      context 'when repo is not part of a team' do
        it 'creates a Services team and adds user to the new team' do
          token = 'abc123'
          username = 'testuser'
          repo_name = 'testing/repo' # from fixture
          team_id = 1234 # from fixture
          api = GithubApi.new(token)
          stub_repo_with_org_request(repo_name, token)
          stub_empty_repo_teams_request(repo_name, token)
          stub_user_teams_request(token)
          stub_team_creation_request('testing', repo_name, token)
          add_user_request = stub_add_user_to_team_request(
            username,
            team_id,
            token
          )

          expect(api.add_user_to_repo(username, repo_name)).to be_true
          expect(add_user_request).to have_been_requested
        end
      end
    end

    context 'when repo is not part of an organization' do
      it 'adds user as collaborator' do
        token = 'abc123'
        username = 'testuser'
        repo_name = 'testing/repo'
        team_id = 1234 # from fixture
        api = GithubApi.new(token)
        stub_repo_request(repo_name, token)
        add_user_request = stub_add_user_to_repo_request(
          username,
          repo_name,
          token
        )

        expect(api.add_user_to_repo(username, repo_name)).to be_true
        expect(add_user_request).to have_been_requested
      end
    end
  end

  describe '#repos' do
    it 'fetches all repos from Github' do
      auth_token = 'authtoken'
      api = GithubApi.new(auth_token)
      stub_repo_requests(auth_token)

      repos = api.repos

      expect(repos.size).to eq 4
    end
  end

  describe '#create_hook' do
    context 'when hook does not exist' do
      it 'creates pull request web hook' do
        full_repo_name = 'jimtom/repo'
        callback_endpoint = 'http://example.com'
        request = stub_hook_creation_request(full_repo_name, callback_endpoint)
        api = GithubApi.new(AuthenticationHelper::GITHUB_TOKEN)

        api.create_hook(full_repo_name, callback_endpoint)

        expect(request).to have_been_requested
      end

      it 'yields hook' do
        full_repo_name = 'jimtom/repo'
        callback_endpoint = 'http://example.com'
        request = stub_hook_creation_request(full_repo_name, callback_endpoint)
        api = GithubApi.new(AuthenticationHelper::GITHUB_TOKEN)
        yielded = false

        api.create_hook(full_repo_name, callback_endpoint) do |hook|
          yielded = true
        end

        expect(request).to have_been_requested
        expect(yielded).to be_true
      end
    end

    context 'when hook already exists' do
      it 'does not raise' do
        full_repo_name = 'jimtom/repo'
        callback_endpoint = 'http://example.com'
        stub_failed_hook_creation_request(full_repo_name, callback_endpoint)
        api = GithubApi.new(AuthenticationHelper::GITHUB_TOKEN)

        expect do
          api.create_hook(full_repo_name, callback_endpoint)
        end.not_to raise_error
      end
    end
  end

  describe '#remove_hook' do
    it 'removes pull request web hook' do
      repo_name = 'test-user/repo'
      hook_id = '123'
      stub_hook_removal_request(repo_name, hook_id)
      api = GithubApi.new('sometoken')

      response = api.remove_hook(repo_name, hook_id)

      expect(response).to be_true
    end
  end

  describe '#commit_files' do
    it 'returns changed files in commit' do
      github_token = 'githubtoken'
      github_api = GithubApi.new(github_token)
      full_repo_name = 'org/repo'
      commit_sha = 'commitsha'
      stub_commit_request(full_repo_name, commit_sha)

      files = github_api.commit_files(full_repo_name, commit_sha)

      expect(files).to have(1).item
      expect(files.first.filename).to eq 'file1.rb'
    end
  end

  describe '#pull_request_files' do
    it 'returns changed files in a pull request' do
      api = GithubApi.new('authtoken')
      pull_request = double(:pull_request, full_repo_name: 'thoughtbot/hound')
      pull_request_number = 123
      commit_sha = 'abc123'
      github_token = 'authtoken'
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
    end
  end
end

describe GithubApi, '#add_comment' do
  it 'adds comment to GitHub' do
    api = GithubApi.new('authtoken')
    repo_name = 'test/repo'
    pull_request_number = 2
    comment = 'test comment'
    commit_sha = 'commitsha'
    file = 'test.rb'
    line_number = 123
    request = stub_comment_request(
      repo_name,
      pull_request_number,
      comment,
      commit_sha,
      file,
      line_number
    )

    api.add_comment(
      repo_name: repo_name,
      pull_request_number: pull_request_number,
      comment: 'test comment',
      commit: commit_sha,
      filename: file,
      line_number: line_number
    )

    expect(request).to have_been_requested
  end
end

describe GithubApi, '#user_teams' do
  it "returns user's teams" do
    token = 'abc123'
    teams = ['thoughtbot']
    client = double(user_teams: teams)
    Octokit::Client.stub(new: client)
    api = GithubApi.new(token)

    user_teams = api.user_teams

    expect(user_teams).to eq teams
  end
end
