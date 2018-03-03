# frozen_string_literal: true

require "rails_helper"

describe Membership, 'associations' do
  it { should belong_to(:repo) }
  it { should belong_to(:user) }
end
