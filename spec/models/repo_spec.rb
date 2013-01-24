require 'spec_helper'

describe Repo do
  it 'validates uniqueness of github_id' do
    Repo.create(active: false, github_id: 123)

    should validate_uniqueness_of :github_id
  end

  it { should validate_presence_of :github_id }

  describe '.find_by_github_id' do
    context 'with existing repo' do
      it 'finds repo' do
        repo = Repo.create(github_id: 123, active: false)

        expect(Repo.find_by_github_id(123)).to eq repo
      end
    end

    context 'without existing repo' do
      it 'returns null repo' do
        repo = Repo.find_by_github_id(456)

        expect(repo.id).to be_nil
        expect(repo.github_id).to eq 456
      end
    end
  end
end

describe NullRepo do
  describe '#activate' do
    it 'creates an active repo' do
      repo = NullRepo.new(github_id: 456)

      repo.activate

      active_repo = Repo.where(github_id: 456, active: true)
      expect(active_repo).to_not be_nil
    end
  end
end
