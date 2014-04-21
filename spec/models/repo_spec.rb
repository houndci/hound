require 'spec_helper'

describe Repo, 'associations' do
  it { should have_many(:users).through(:memberships) }
  it { should have_many :builds }
end

describe Repo, 'validations' do
  it 'validates uniqueness of github_id' do
    create(:repo)

    expect(subject).to validate_uniqueness_of(:github_id)
  end

  it { should validate_presence_of :full_github_name }
  it { should validate_presence_of :github_id }
end
