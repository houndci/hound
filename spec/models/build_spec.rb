require 'spec_helper'

describe Build, '#run' do
  context 'with violations' do
    it 'checks style guide and notifies github of the failed build' do
      pull_request = pull_request_stub
      api = mock(
        create_pending_status: nil,
        create_failure_status: nil,
        pull_request_files: []
      )
      style_guide = mock(violations: ['something failed'], check: nil)
      GithubApi.stubs(new: api)
      StyleGuide.stubs(new: style_guide)

      build = Build.new(pull_request)
      build.run

      expect(api).to have_received(:create_pending_status).
        with(pull_request.full_repo_name, pull_request.head_sha, 'Hound is working...')
      expect(api).to have_received(:create_failure_status).
        with(pull_request.full_repo_name, pull_request.head_sha, 'Hound does not approve')
    end
  end

  context 'without violations' do
    it 'checks style guide and notifies github of the passing build' do
      pull_request = pull_request_stub
      api = mock(
        create_pending_status: nil,
        create_successful_status: nil,
        pull_request_files: []
      )
      GithubApi.stubs(new: api)

      build = Build.new(pull_request)
      build.run

      expect(api).to have_received(:create_pending_status).
        with(pull_request.full_repo_name, pull_request.head_sha, 'Hound is working...')
      expect(api).to have_received(:create_successful_status).
        with(pull_request.full_repo_name, pull_request.head_sha, 'Hound approves')
    end
  end
end

describe Build, '#pull_request_additions' do
  it 'returns additions of the pull request' do
    repo_name = 'test-user/repo'
    pull_request = pull_request_stub(full_repo_name: repo_name)
    stub_pull_request_files_request(repo_name)

    build = Build.new(pull_request)
    additions = build.send(:pull_request_additions)

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

describe Build, '#valid?' do
  context 'with synchronize action' do
    it 'returns true' do
      pull_request = pull_request_stub(action: 'synchronize')

      build = Build.new(pull_request)

      expect(build).to be_valid
    end
  end

  context 'with closed action' do
    it 'returns false' do
      pull_request = pull_request_stub(action: 'closed')
      build = Build.new(pull_request)

      expect(build).not_to be_valid
    end
  end

  context 'with invalid pull_request' do
    it 'returns false' do
      pull_request = pull_request_stub(valid?: false)
      build = Build.new(pull_request)

      expect(build).not_to be_valid
    end
  end

  context 'with deactivated repo' do
    it 'returns false' do
      repo = create(:repo, active: false)
      pull_request = pull_request_stub(github_repo_id: repo.github_id)
      build = Build.new(pull_request)

      expect(build).not_to be_valid
    end
  end

  context 'with no repo' do
    it 'returns false' do
      pull_request = pull_request_stub(github_repo_id: nil)
      build = Build.new(pull_request)

      expect(build).not_to be_valid
    end
  end
end

def pull_request_stub(options = {})
  repo = create(:active_repo)
  attributes = {
    action: 'opened',
    full_repo_name: repo.full_github_name,
    github_repo_id: repo.github_id,
    head_sha: '123abc',
    number: 4,
    valid?: true
  }.merge(options)

  stub(attributes)
end
