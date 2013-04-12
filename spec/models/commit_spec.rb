require 'fast_spec_helper'
require 'app/models/commit'

describe Commit do
  describe '#full_repo_name' do
    it 'returns full repo name' do
      commit = Commit.new(payload)

      expect(commit.full_repo_name).to eq 'thoughtbot/hound'
    end
  end

  describe '#id' do
    it 'returns commit sha' do
      commit = Commit.new(payload)

      expect(commit.id).to eq 'e40d48166331d9538200de2aac5605f9a1ce6d70'
    end
  end

  describe '#previous_commit_id' do
    it 'returns previous commit sha' do
      commit = Commit.new(payload)

      expect(commit.previous_commit_id).to eq 'c6035b8c15056c1d3a6680213065455ba9b47ea6'
    end
  end

  describe '#pusher' do
    it 'returns pusher username' do
      commit = Commit.new(payload)

      expect(commit.pusher).to eq 'salbertson'
    end
  end

  def payload
    File.read('spec/support/fixtures/commit_payload.json')
  end
end
