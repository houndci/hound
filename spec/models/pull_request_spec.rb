require 'fast_spec_helper'
require 'app/models/pull_request'
require 'json'

describe PullRequest do
  let(:payload) { File.read('spec/support/fixtures/pull_request_payload.json') }
  let(:pull_request) { PullRequest.new(payload) }

  describe '#allowed?' do
    context 'with closed action' do
      it 'returns false' do
        payload.gsub!('opened', 'closed')

        expect(pull_request).not_to be_allowed
      end
    end

    context 'with syncronize action' do
      it 'returns true' do
        payload.gsub!('opened', 'synchronize')

        expect(pull_request).to be_allowed
      end
    end

    context 'without pull_request data' do
      it 'returns false' do
        payload.gsub!('pull_request', '')

        expect(pull_request).not_to be_allowed
      end
    end
  end

  describe '#full_repo_name' do
    it 'returns the full repository name' do
      expect(pull_request.full_repo_name).to eq 'salbertson/life'
    end
  end

  describe '#head_sha' do
    it 'returns the sha hash of the latest commit' do
      expect(pull_request.head_sha).to eq '498b81cd038f8a3ac02f035a8537b7ddcff38a81'
    end
  end

  describe '#number' do
    it 'returns the number of the pull request' do
      expect(pull_request.number).to eq 2
    end
  end

  describe '#repo_owner' do
    it 'returns the username of the repository owner' do
      expect(pull_request.repo_owner).to eq 'salbertson'
    end
  end
end
