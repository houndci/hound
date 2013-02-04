require 'fast_spec_helper'
require 'app/models/pull_request'
require 'app/models/git_diff'
require 'json'

describe PullRequest do
  describe '#additions' do
    it 'returns diff additions' do
      diff = stub(additions: ['one', 'two'])
      GitDiff.stubs(new: diff)
      payload = File.read('spec/support/fixtures/github_pull_request_payload.json')
      pull_request = PullRequest.new(payload)

      expect(pull_request.additions).to eq ['one', 'two']
      expect(GitDiff).to have_received(:new).with(pull_request.diff_url)
    end
  end
end
