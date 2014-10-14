require "spec_helper"

describe "Stripe Webhooks" do
  describe "customer.subscription.deleted" do
    it "passes the stripe customer id to RepoDeactivator" do
      stub_event "evt_customer_subscription_deleted"
      stripe_customer_id = "cus_00000000000000"
      deactivator_double = double("deactivator")
      allow(deactivator_double).to receive(:deactivate_all)
      allow(RepoDeactivator).to receive(:new).with(stripe_customer_id).
        and_return(deactivator_double)

      post "/stripe-event", id: "evt_customer_subscription_deleted"

      expect(RepoDeactivator).to have_received(:new).with(stripe_customer_id)
    end

    def stub_event(fixture_id, status = 200)
      stub_request(
        :get,
        "https://api.stripe.com/v1/events/#{fixture_id}"
      ).to_return(
        status: status,
        body: File.read("spec/support/fixtures/#{fixture_id}.json")
      )
    end
  end
end
