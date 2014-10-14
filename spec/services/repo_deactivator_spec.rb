require "spec_helper"

describe RepoDeactivator do
  describe "#deactivate_all" do
    it "deactivates all of a users paid repos" do
      user = create(:user, stripe_customer_id: "cus_123")
      subscriptions = create_list(:subscription, 2, user: user)

      RepoDeactivator.new(user.stripe_customer_id).deactivate_all

      subscriptions.each do |subscription|
        expect(subscription.repo.active?).to eq false
      end
    end
  end
end
