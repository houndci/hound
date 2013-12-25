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

  describe '#pull_request_files' do
    it 'returns file content of changed files' do
      api = GithubApi.new('authtoken')
      pull_request = double(
        full_repo_name: 'thoughtbot/hound',
        number: 69,
        head_sha: '123abc'
      )
      stub_pull_request_files_request(
        pull_request.full_repo_name,
        pull_request.number,
        'authtoken'
      )
      stub_contents_request(pull_request.full_repo_name, pull_request.head_sha)

      files = api.pull_request_files(pull_request.full_repo_name, pull_request.number)
      file = files.first

      expect(files).to have(1).item
      expect(file.filename).to eq 'config/unicorn.rb'
      expect(file.patch).to include 'preload_app true'
    end
  end
end

describe GithubApi, '#create_status' do
  describe '#create_status' do
    it 'creates a failure GitHub status' do
      api = GithubApi.new('authtoken')
      repo_name = 'test-user/repo'
      sha = 'abcdefg'
      url = 'http://example.com'
      options = { description: 'Failed!', target_url: url }
      stub_status_creation_request(repo_name, sha, 'failure', 'Failed!', url)

      response = api.create_status(repo_name, sha, :failure, options)

      expect(response.id).not_to be_nil
    end
  end
end
