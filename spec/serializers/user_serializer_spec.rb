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

  describe "#plan_max" do
    it "returns the number of subscriptions allowed within the current plan" do
      subscription = create(:subscription)
      user = create(:user, subscriptions: [subscription])
      serializer = UserSerializer.new(user)

      expect(serializer.object.plan_max).to eq 4
    end
  end
end
