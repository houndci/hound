require "rails_helper"

describe Ownership, "associations" do
  it { should belong_to(:owner) }
  it { should belong_to(:user) }
end
