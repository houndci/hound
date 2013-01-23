require 'spec_helper'

describe Repo do
  before do
    Repo.create(active: false, github_id: 123)
  end

  it { should validate_uniqueness_of :github_id }
  it { should validate_presence_of :github_id }
end
