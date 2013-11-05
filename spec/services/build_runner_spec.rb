require 'spec_helper'

describe BuildRunner, '#run' do
end

describe BuildRunner, '#valid?' do
  context 'with synchronize action' do
    it 'returns true' do
      pull_request = pull_request_stub(action: 'synchronize')

      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).to be_valid
    end
  end

  context 'with closed action' do
    it 'returns false' do
      pull_request = pull_request_stub(action: 'closed')
      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).not_to be_valid
    end
  end

  context 'with invalid pull_request' do
    it 'returns false' do
      pull_request = pull_request_stub(valid?: false)
      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).not_to be_valid
    end
  end

  context 'with deactivated repo' do
    it 'returns false' do
      repo = create(:repo, active: false)
      pull_request = pull_request_stub(github_repo_id: repo.github_id)
      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).not_to be_valid
    end
  end

  context 'with no repo' do
    it 'returns false' do
      pull_request = pull_request_stub(github_repo_id: nil)
      build_runner = BuildRunner.new(pull_request)

      expect(build_runner).not_to be_valid
    end
  end
end

def pull_request_stub(options = {})
  user = create(:user)
  repo = create(:active_repo)
  create(:membership, user: user, repo: repo)
  attributes = {
    action: 'opened',
    full_repo_name: repo.full_github_name,
    github_repo_id: repo.github_id,
    head_sha: '123abc',
    number: 4,
    valid?: true
  }.merge(options)

  double(attributes)
end
