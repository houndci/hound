require 'spec_helper'

describe User do
  it { should have_many(:repos).through(:memberships) }
  it { should validate_presence_of :github_username }

  describe '#create' do
    it 'generates a remember_token' do
      user = build(:user)
      SecureRandom.stub(hex: 'remembertoken')

      user.save

      expect(SecureRandom).to have_received(:hex).with(20)
      expect(user.remember_token).to eq 'remembertoken'
    end
  end

  describe '#to_s' do
    it 'returns GitHub username' do
      user = build(:user)

      user_string = user.to_s

      expect(user_string).to eq user.github_username
    end
  end

  describe '#has_repos_with_missing_information?' do
    context 'with repo without organization info' do
      it 'returns true' do
        user = create(:user)
        repo = create(:repo, in_organization: nil)
        user.repos << repo

        expect(user).to have_repos_with_missing_information
      end
    end

    context 'with repo without privacy info' do
      it 'return true' do
        user = create(:user)
        repo = create(:repo, private: nil)
        user.repos << repo

        expect(user).to have_repos_with_missing_information
      end
    end

    context 'with repo without organization and privacy info' do
      it 'returns true' do
        user = create(:user)
        repo = create(:repo, in_organization: nil, private: nil)
        user.repos << repo

        expect(user).to have_repos_with_missing_information
      end
    end

    context 'with repo with organization and privacy info' do
      it 'returns false' do
        user = create(:user)
        repo = create(:repo, in_organization: true, private: true)
        user.repos << repo

        expect(user).not_to have_repos_with_missing_information
      end
    end
  end
end
