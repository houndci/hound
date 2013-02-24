require 'spec_helper'

describe Repo do
  it 'validates uniqueness of github_id' do
    user = create(:user)
    user.repos.create(active: false, github_id: 123, full_github_name: 'repo')

    expect(subject).to validate_uniqueness_of :github_id
  end

  it 'validates uniqueness of full_github_name' do
    user = create(:user)
    user.repos.create(active: false, github_id: 123, full_github_name: 'repo')

    expect(subject).to validate_uniqueness_of :full_github_name
  end

  it { should belong_to :user }
  it { should validate_presence_of :full_github_name }
  it { should validate_presence_of :github_id }
end
