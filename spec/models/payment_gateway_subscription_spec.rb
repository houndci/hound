require "rails_helper"

describe PaymentGatewaySubscription do
  describe "#subscribe" do
    it "adds the repo ID to the subscription's metadata" do
      repo_id = 1
      stripe_subscription = MockStripeSubscription.new(repo_ids: ["1"])
      user = instance_double("User")
      subscription = PaymentGatewaySubscription.new(
        stripe_subscription: stripe_subscription,
        user: user,
      )

      subscription.subscribe(repo_id)

      expect(stripe_subscription).to be_saved
      expect(stripe_subscription.metadata).to eq("repo_ids" => repo_id.to_s)
    end
  end

  describe "#unsubscribe" do
    it "removes the repo ID from the subscription's metadata" do
      repo_id = 1
      stripe_subscription = MockStripeSubscription.new(repo_ids: [repo_id])
      user = instance_double("User")
      subscription = PaymentGatewaySubscription.new(
        stripe_subscription: stripe_subscription,
        user: user,
      )

      subscription.unsubscribe(repo_id)

      expect(stripe_subscription).to be_saved
      expect(stripe_subscription.metadata).to eq("repo_ids" => nil)
    end
  end

  class MockStripeSubscription
    attr_accessor :metadata, :plan

    def initialize(repo_ids:)
      @metadata = { "repo_ids" => repo_ids.join(",") }
    end

    def save
      @save = true
    end

    def delete; end

    def saved?
      !!@save
    end
  end

  class MockLegacyStripeSubscription < MockStripeSubscription
    def initialize(repo_id:)
      @metadata = { "repo_id" => repo_id.to_s }
    end
  end
end
