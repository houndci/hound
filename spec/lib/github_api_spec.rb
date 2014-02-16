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
      pull_request = double(:pull_request, full_repo_name: 'thoughtbot/hound')
      pull_request_number = 123
      commit_sha = 'abc123'
      stub_pull_request_files_request(
        pull_request.full_repo_name,
        pull_request_number,
        'authtoken'
      )
      stub_contents_request(
        repo_name: pull_request.full_repo_name,
        sha: commit_sha
      )

      files = api.pull_request_files(pull_request.full_repo_name, pull_request_number)
      file = files.first

      expect(files).to have(1).item
      expect(file.filename).to eq 'config/unicorn.rb'
      expect(file.patch).to include 'preload_app true'
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
