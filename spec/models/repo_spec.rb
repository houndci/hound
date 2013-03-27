require 'spec_helper'

describe Repo do
  it 'validates uniqueness of github_id' do
    create(:repo)

    should validate_uniqueness_of :github_id
  end

  it { should validate_presence_of :name }
  it { should validate_presence_of :full_github_name }
  it { should validate_presence_of :github_id }
end
