require 'fast_spec_helper'
require 'lib/github_api'

describe GithubApi do
  describe '#get_repos' do
    it 'fetches repos from Github' do
      auth_token = 'authtoken'
      api = GithubApi.new(auth_token)
      stub_repos_request(auth_token)

      repos = api.get_repos

      expect(repos.size).to eq 1
    end
  end

  describe '#create_pull_request_hook' do
    it 'creates pull request web hook' do
      auth_token = 'authtoken'
      api = GithubApi.new(auth_token)
      full_repo_name = 'jimtom/repo'
      callback_endpoint = 'http://example.com'
      stub_hook_creation_request(auth_token, full_repo_name, callback_endpoint)

      response = api.create_pull_request_hook(full_repo_name, callback_endpoint)

      expect(response.id).not_to be_nil
    end
  end

  describe '#create_status' do
    it 'creates status on GitHub' do
      auth_token = 'authtoken'
      api = GithubApi.new(auth_token)
      full_repo_name = 'jimtom/repo'
      commit_hash = 'abc123'
      state = 'pending'
      description = 'Hound approves'
      api = GithubApi.new(auth_token)
      stub_status_creation_request(auth_token, full_repo_name, commit_hash, state, description)

      response = api.create_status(full_repo_name, commit_hash, state, description)

      expect(response).not_to be_nil
    end
  end
end
