require 'spec_helper'

describe Repo do
  it 'validates uniqueness of github_id' do
    create(:repo)

    expect(subject).to validate_uniqueness_of(:github_id).scoped_to(:user_id)
  end

  it { should belong_to :user }
  it { should have_many :builds }
  it { should validate_presence_of :name }
  it { should validate_presence_of :full_github_name }
  it { should validate_presence_of :github_id }
end
