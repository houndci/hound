require 'fast_spec_helper'
require 'app/models/pull_request'
require 'json'
require 'active_support/core_ext/object/blank'

describe PullRequest do
  let(:payload) { File.read('spec/support/fixtures/pull_request_payload.json') }
  let(:pull_request) { PullRequest.new(payload) }

  describe '#valid?' do
    context 'with pull_request data' do
      it 'returns true' do
        expect(pull_request).to be_valid
      end
    end

    context 'without pull_request data' do
      it 'returns false' do
        payload.gsub!('pull_request', '')

        expect(pull_request).not_to be_valid
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

  describe '#github_repo_id' do
    it 'returns the github id of the repository' do
      expect(pull_request.github_repo_id).to eq 2937493
    end
  end
end
