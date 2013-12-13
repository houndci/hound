require 'spec_helper'

describe User, 'associations' do
  it { should have_many(:repos).through(:memberships) }
end

describe User, 'validations' do
  it { should validate_presence_of :github_username }
end

describe User, '.create' do
  it 'generates a remember_token' do
    user = build(:user)
    SecureRandom.stub(hex: 'remembertoken')

    user.save

    expect(SecureRandom).to have_received(:hex).with(20)
    expect(user.remember_token).to eq 'remembertoken'
  end
end

describe User, '#to_s' do
  it 'returns GitHub username' do
    user = build(:user)

    user_string = user.to_s

    expect(user_string).to eq user.github_username
  end
end
