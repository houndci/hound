require 'spec_helper'

describe BuildRunner, '#run' do
  let(:repo) { create(:repo) }
  let(:pull_request) do
    stub(
      full_repo_name: 'test-user/repo',
      head_sha: '123abc',
      number: 4,
      github_repo_id: repo.github_id
    )
  end

  context 'with violations' do
    it 'checks style guide and notifies github of the failed build' do
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
    repo_name = 'test-user/repo'
    repo = stub(github_token: '123abc')
    pull_request = stub(full_repo_name: repo_name, number: 1, github_repo_id: 1)
    Repo.stubs(where: [repo])
    stub_pull_request_files_request(repo_name)

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

describe BuildRunner, '#valid?' do
  let(:repo) { stub(active?: true, id: 123) }
  let(:pull_request) do
    stub(valid?: true, action: 'opened', github_repo_id: repo.id)
  end

  before do
    Repo.stubs(where: [repo])
  end

  context 'with syncronize action' do
    it 'returns true' do
      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).to be_valid
    end
  end

  context 'with closed action' do
    it 'returns false' do
      pull_request.stubs(action: 'closed')

      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).not_to be_valid
    end
  end

  context 'with invalid pull_request' do
    it 'returns false' do
      pull_request.stubs(valid?: false)

      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).not_to be_valid
    end
  end

  context 'with deactivated repo' do
    it 'returns false' do
      repo.stubs(active?: false)

      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).not_to be_valid
    end
  end

  context 'with no repo' do
    it 'returns false' do
      Repo.stubs(where: [])

      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).not_to be_valid
    end
  end
end
