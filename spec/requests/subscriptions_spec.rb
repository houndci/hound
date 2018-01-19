require "rails_helper"

RSpec.describe "Subscriptions" do
  context "when event is for subscription deleted" do
    it "deletes all subscription records and deactivates their repos" do
      user = create(:user, token: "foobar")
      subscription = create(:subscription, user: user)
      create(:membership, user: user, repo: subscription.repo)
      params = {
        "type": "customer.subscription.deleted",
        "object": "event",
        "data": {
          "object": {
            "id": subscription.stripe_subscription_id,
            "object": "subscription",
          },
        },
      }

      post "/deleted_subscriptions", params: params

      subscription.reload
      expect(response).to be_ok
      expect(subscription).to be_deleted
      expect(subscription.repo).not_to be_active
    end
  end
end
