require "rails_helper"

RSpec.describe UserSerializer do
  describe "#subscribed_repo_count" do
    it "is the number of repos the user is subscribed to" do
      subscribed_repos = class_double(Repo, count: 1)
      user = instance_double(User, subscribed_repos: subscribed_repos)
      serializer = UserSerializer.new(user)

      expect(serializer.subscribed_repo_count).to eq 1
    end
  end

  describe "#tier_allowance" do
    it "is the number of subscriptions allowed within the current tier" do
      current_tier = instance_double(Pricing, allowance: 4)
      user = instance_double(User, current_tier: current_tier)
      serializer = UserSerializer.new(user)

      expect(serializer.tier_allowance).to eq 4
    end
  end
end
