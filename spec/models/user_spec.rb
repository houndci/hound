require 'spec_helper'

describe User do
  describe '.create' do
    it 'generates a remember_token' do
      SecureRandom.stub(:hex).with(20).and_return('remembertoken')
      user = User.new(github_username: 'jimtom')

      user.save

      expect(user.remember_token).to eq 'remembertoken'
    end
  end
end
