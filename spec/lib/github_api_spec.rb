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
      allow(api).to receive(:update_repo_hook_id).with(full_repo_name: true)
      stub_hook_creation_request(auth_token, full_repo_name, callback_endpoint)

      response = api.create_pull_request_hook(full_repo_name, callback_endpoint)

      expect(response.id).not_to be_nil
    end
  end

  describe '#remove_pull_request_hook' do
    it 'removes pull request web hook' do
      repo_name = 'test-user/repo'
      hook_id = '123'
      stub_hook_removal_request(repo_name, hook_id)
      api = GithubApi.new('sometoken')

      response = api.remove_pull_request_hook(repo_name, hook_id)

      expect(response).to be_true
    end
  end

  describe '#create_pending_status' do
    it 'creates a pending GitHub status' do
      api = GithubApi.new('authtoken')
      repo_name = 'test-user/repo'
      head_sha = 'abcdefg'
      stub_status_creation_request(repo_name, head_sha, 'pending', 'Working...')

      response = api.create_pending_status(repo_name, head_sha, 'Working...')

      expect(response.id).not_to be_nil
    end
  end

  describe '#create_failure_status' do
    it 'creates a failure GitHub status' do
      api = GithubApi.new('authtoken')
      repo_name = 'test-user/repo'
      head_sha = 'abcdefg'
      target_url = 'http://example.com'
      stub_failure_status_creation_request(repo_name, head_sha, 'failure', 'FAIL', target_url)

      response = api.create_failure_status(repo_name, head_sha, 'FAIL', target_url)

      expect(response.id).not_to be_nil
    end
  end

  describe '#pull_request_files' do
    it 'returns file content of changed files' do
      api = GithubApi.new('authtoken')
      pull_request = stub(full_repo_name: 'thoughtbot/hound', number: 69)
      stub_pull_request_files_request(
        pull_request.full_repo_name,
        pull_request.number,
        'authtoken'
      )
      stub_contents_request(pull_request.full_repo_name)

      files = api.pull_request_files(pull_request)

      expect(files).to eq ['some test code']
    end
  end
end
