require "spec_helper"

describe DeactivatePaidRepos do
  describe ".run" do
    it "deactivates all of a user's paid repos" do
      user = create(:user, stripe_customer_id: "cus_123")
      repo = create(:repo, :active, users: [user])
      subscriptions = create_list(:subscription, 2, user: user)

      DeactivatePaidRepos.run(user.stripe_customer_id)

      expect(repo).to be_active
      subscriptions.each do |subscription|
        expect(subscription.repo).not_to be_active
      end
    end
  end
end
