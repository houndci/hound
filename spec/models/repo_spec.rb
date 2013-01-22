require 'spec_helper'

describe Repo do
  it 'validates uniqueness of github_id' do
    Repo.create(active: false, github_id: 123)

    should validate_uniqueness_of :github_id
  end

  it { should validate_presence_of :github_id }
end
