require 'fast_spec_helper'
require 'lib/github_api'

describe GithubApi do
  describe '#get_repos' do
    it 'fetches all repos from Github' do
      auth_token = 'authtoken'
      api = GithubApi.new(auth_token)
      stub_repo_requests(auth_token)

      repos = api.get_repos

      expect(repos.size).to eq 2
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

  describe '#create_pending_status' do
    it 'creates a pending GitHub status' do
      pull_request = stub(full_repo_name: 'jimtom/repo', sha: 'abc123')
      api = GithubApi.new('authtoken')
      stub_status_creation_request(
        'authtoken',
        'jimtom/repo',
        'abc123',
        'pending',
        'Working...'
      )

      response = api.create_pending_status(pull_request, 'Working...')

      expect(response.id).not_to be_nil
    end
  end
end
