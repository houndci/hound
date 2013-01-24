require 'spec_helper'

describe Repo do
  it 'validates uniqueness of github_id' do
    user = create(:user)
    user.repos.create(active: false, github_id: 123)

    should validate_uniqueness_of :github_id
  end

  it { should validate_presence_of :github_id }

  describe '.find_by_github_id_and_user' do
    context 'with existing repo' do
      it 'finds repo' do
        user = create(:user)
        repo = user.repos.create(github_id: 123, active: false)

        expect(Repo.find_by_github_id_and_user(123, user)).to eq repo
      end
    end

    context 'without existing repo' do
      it 'returns null repo' do
        user = build_stubbed(:user)
        repo = Repo.find_by_github_id_and_user(456, user)

        expect(repo.id).to be_nil
        expect(repo.user).to eq user
        expect(repo.github_id).to eq 456
      end
    end
  end
end
