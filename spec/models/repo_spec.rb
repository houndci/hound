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

describe Repo, '.find_or_create_with' do
  context 'with existing repo' do
    it 'updates attributes' do
      repo = create(:repo)

      found_repo = Repo.find_or_create_with(github_id: repo.github_id)

      expect(Repo.count).to eq 1
      expect(found_repo).to eq repo
    end
  end

  context 'with new repo' do
    it 'creates repo with attributes' do
      attributes = build(:repo).attributes
      repo = Repo.find_or_create_with(attributes)

      expect(Repo.count).to eq 1
      expect(repo).to be_present
    end
  end
end
