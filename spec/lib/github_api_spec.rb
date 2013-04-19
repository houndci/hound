require 'fast_spec_helper'
require 'lib/github_api'
require 'json'

describe GithubApi do
  describe '#repos' do
    it 'fetches all repos from Github' do
      auth_token = 'authtoken'
      api = GithubApi.new(auth_token)
      stub_repo_requests(auth_token)

      repos = api.repos

      expect(repos.size).to eq 4
    end
  end

  describe '#create_pull_request_hook' do
    it 'creates pull request web hook' do
      auth_token = 'authtoken'
      api = GithubApi.new(auth_token)
      full_repo_name = 'jimtom/repo'
      callback_endpoint = 'http://example.com'
      api.stubs(:update_repo_hook_id).with(full_repo_name: true)
      stub_hook_creation_request(auth_token, full_repo_name, callback_endpoint)

      response = api.create_pull_request_hook(full_repo_name, callback_endpoint)

      expect(response.id).not_to be_nil
    end
  end

  describe '#remove_pull_request_hook' do
    it 'removes pull request web hook' do
      auth_token = 'authtoken'
      api = GithubApi.new(auth_token)
      repo = build_stubbed(:repo, active: true)
      stub_hook_removal_request(auth_token, repo.full_github_name, repo.hook_id)

      response = api.remove_pull_request_hook(
        repo.full_github_name,
        repo.hook_id
      )

      expect(response).to be_true
    end
  end

  describe '#create_pending_status' do
    it 'creates a pending GitHub status' do
      commit = stub(full_repo_name: 'jimtom/repo', id: 'abc123')
      api = GithubApi.new('authtoken')
      stub_status_creation_request(
        'authtoken',
        'jimtom/repo',
        'abc123',
        'pending',
        'Working...'
      )

      response = api.create_pending_status(commit, 'Working...')

      expect(response.id).not_to be_nil
    end
  end

  describe '#patch' do
    it 'returns diff patch' do
      api = GithubApi.new('authtoken')
      commit = stub(full_repo_name: 'jimtom/repo', previous_commit_id: '123', id: '456')
      stub_patch_request('jimtom/repo', '123', '456')
      json = JSON.parse(File.read('spec/support/fixtures/compare_payload.json'))

      patch = api.patch(commit)

      expect(patch).to eq json['files'][0]['patch']
    end
  end
end
