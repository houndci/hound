require "rails_helper"

describe UpdateStripeMetadata do
  describe "#run" do
    context "updates successfully" do
      it "updates stripe metadata with repo id" do
        user = create(:user, stripe_customer_id: stripe_customer_id)
        subscription = create(:subscription, user: user)
        stub_customer_find_request
        stub_subscription_find_request(subscription)
        stripe_update_request =
          stub_subscription_meta_data_update_request(subscription)

        UpdateStripeMetadata.run

        expect(stripe_update_request).to have_been_requested
      end
    end

    context "when repo does not have a subscription" do
      it "does not make a request to Stripe" do
        subscription = create(:subscription)
        stub_customer_find_request
        stripe_update_request =
          stub_subscription_meta_data_update_request(subscription)

        UpdateStripeMetadata.run

        expect(stripe_update_request).not_to have_been_requested
      end

      context "when stripe_customer_id is missing" do
        it "does not make a request to Stripe" do
          user = create(:user, stripe_customer_id: nil)
          repo = create(:repo, private: true)
          create(
            :subscription,
            user: user,
            repo: repo
          )

          UpdateStripeMetadata.run

          stripe_customer_find_request = stub_customer_find_request
          expect(stripe_customer_find_request).not_to have_been_requested
        end
      end
    end
  end
end
