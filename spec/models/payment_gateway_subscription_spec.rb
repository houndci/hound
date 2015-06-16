require "rails_helper"

describe PaymentGatewaySubscription do
  context ".subscribe" do
    context "existing subscription" do
      it "appends id to repo_ids metadata" do
        stripe_subscription = MockStripeSubscription.new(repo_ids: [1])
        subscription = PaymentGatewaySubscription.new(stripe_subscription)

        expect(stripe_subscription.metadata["repo_ids"]).to eq "1"

        subscription.subscribe(2)

        expect(stripe_subscription.metadata["repo_ids"]).to eq "1,2"
      end

      it "converts legacy format to new format" do
        legacy_subscription = MockLegacyStripeSubscription.new(repo_id: 1)
        subscription = PaymentGatewaySubscription.new(legacy_subscription)

        expect(legacy_subscription.metadata["repo_id"]).to eq "1"

        subscription.subscribe(2)

        expect(legacy_subscription.metadata["repo_id"]).to be_nil
        expect(legacy_subscription.metadata["repo_ids"]).to eq "1,2"
      end
    end
  end

  context ".unsubscribe" do
    it "removes repo_id from repo_ids" do
      stripe_subscription = MockStripeSubscription.new(repo_ids: [1, 2])
      allow(stripe_subscription).to receive(:delete)
      allow(stripe_subscription).to receive(:save)
      subscription = PaymentGatewaySubscription.new(stripe_subscription)

      subscription.unsubscribe(2)

      expect(stripe_subscription.metadata["repo_ids"]).to eq "1"
      expect(stripe_subscription).not_to have_received(:delete)
      expect(stripe_subscription).to have_received(:save)
    end

    it "doesn't blow up when unsubscribing from a legacy subscription" do
      legacy_subscription = MockLegacyStripeSubscription.new(repo_id: 1)
      allow(legacy_subscription).to receive(:delete)
      allow(legacy_subscription).to receive(:save)
      subscription = PaymentGatewaySubscription.new(legacy_subscription)

      subscription.unsubscribe(1)

      expect(legacy_subscription).to have_received(:delete)
      expect(legacy_subscription).not_to have_received(:save)
    end
  end

  class MockStripeSubscription
    attr_accessor :quantity, :metadata

    def initialize(repo_ids:)
      @quantity = repo_ids.count
      @metadata = { "repo_ids" => repo_ids.join(",") }
    end

    def save; end

    def delete; end
  end

  class MockLegacyStripeSubscription < MockStripeSubscription
    def initialize(repo_id:)
      @quantity = 1
      @metadata = { "repo_id" => repo_id.to_s }
    end
  end
end
