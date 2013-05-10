require 'spec_helper'

describe BuildRunner, '#run' do
  context 'with violations' do
    it 'checks style guide and notifies github of the failed build' do
      create(:user, github_username: pull_request.repo_owner, github_token: 'abcdef')
      api = mock(
        create_pending_status: nil,
        create_failure_status: nil,
        pull_request_files: []
      )
      style_guide = mock(violations: ['something failed'], check: nil)
      GithubApi.stubs(new: api)
      StyleGuide.stubs(new: style_guide)

      build_runner = BuildRunner.new(pull_request)
      build_runner.run

      expect(api).to have_received(:create_pending_status).
        with(pull_request.full_repo_name, pull_request.head_sha, 'Hound is working...')
      expect(api).to have_received(:create_failure_status).
        with(pull_request.full_repo_name, pull_request.head_sha, 'Hound does not approve')
    end
  end

  context 'without violations' do
    it 'checks style guide and notifies github of the passing build' do
      create(:user, github_username: pull_request.repo_owner, github_token: 'abcdef')
      api = mock(
        create_pending_status: nil,
        create_successful_status: nil,
        pull_request_files: []
      )
      GithubApi.stubs(new: api)

      build_runner = BuildRunner.new(pull_request)
      build_runner.run

      expect(api).to have_received(:create_pending_status).
        with(pull_request.full_repo_name, pull_request.head_sha, 'Hound is working...')
      expect(api).to have_received(:create_successful_status).
        with(pull_request.full_repo_name, pull_request.head_sha, 'Hound approves')
    end
  end
end

describe BuildRunner, '#pull_request_additions' do
  it 'returns additions of the pull request' do
    create(:user, github_username: pull_request.repo_owner, github_token: 'abcdef')
    stub_pull_request_files_request('test-user/repo')

    build_runner = BuildRunner.new(pull_request)
    additions = build_runner.pull_request_additions

    expect(additions).to eq [
      'class HashSyntaxRule < Rule',
      'def violated?(text)',
      'uses_non_preferred_hash_syntax?(text)',
      'end',
      "require 'fast_spec_helper'",
      "require 'app/models/rule'",
      "require 'app/models/hash_syntax_rule'",
      "describe HashSyntaxRule, '#violated?' do",
      'end'
    ]
  end
end

describe BuildRunner, '#api' do
  it 'initializes github api with valid github token' do
    create(:user, github_username: pull_request.repo_owner, github_token: 'abcdef')
    GithubApi.stubs(:new)

    build_runner = BuildRunner.new(pull_request)
    build_runner.send(:api)

    expect(GithubApi).to have_received(:new).with('abcdef')
  end
end

def pull_request
  stub(
    full_repo_name: 'test-user/repo',
    head_sha: '123abc',
    number: 4,
    repo_owner: 'test-user'
  )
end
