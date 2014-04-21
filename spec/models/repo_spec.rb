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

describe Repo, '#update_changed_attributes' do
  it 'updates full_github_name if changed in repo_data' do
    repo = create(:repo)
    repo_data = {
      full_name: 'user/newname',
      id: repo.github_id
    }

    repo.update_changed_attributes(repo_data)

    expect(repo.full_github_name).to eq 'user/newname'
  end
end
