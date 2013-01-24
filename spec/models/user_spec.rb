require 'spec_helper'

describe User do
  it { should validate_presence_of :github_username }

  describe '.create' do
    it 'generates a remember_token' do
      user = build(:user)
      SecureRandom.stubs(hex: 'remembertoken')

      user.save

      expect(SecureRandom).to have_received(:hex).with(20)
      expect(user.remember_token).to eq 'remembertoken'
    end
  end

  describe '#to_s' do
    it 'returns GitHub username' do
      user = build(:user)

      user_string = user.to_s

      expect(user_string).to eq 'jimtom'
    end
  end
end
