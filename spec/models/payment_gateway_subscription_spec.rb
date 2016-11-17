require "rails_helper"

describe PaymentGatewaySubscription do
  describe "#subscribe" do
    it "sets the plan to the upgraded tier" do
      plan = "tier1"
      succ = instance_double("Pricing")
      repo_id = 1
      stripe_subscription = MockStripeSubscription.new(repo_ids: [])
      tier = instance_double("Tier")
      subscription = PaymentGatewaySubscription.new(
        stripe_subscription: stripe_subscription,
        tier: tier,
      )
      allow(succ).to receive(:id).once.with(no_args).and_return(plan)
      allow(tier).to receive(:next).once.with(no_args).and_return(succ)

      subscription.subscribe(repo_id)

      expect(stripe_subscription).to be_saved
      expect(stripe_subscription.metadata).to eq("repo_ids" => repo_id.to_s)
      expect(stripe_subscription.plan).to eq plan
    end
  end

  describe "#unsubscribe" do
    it "sets the plan to the downgraded tier" do
      plan = "basic"
      previous = instance_double("Pricing")
      repo_id = 1
      stripe_subscription = MockStripeSubscription.new(repo_ids: [repo_id])
      tier = instance_double("Tier")
      subscription = PaymentGatewaySubscription.new(
        stripe_subscription: stripe_subscription,
        tier: tier,
      )
      allow(previous).to receive(:id).once.with(no_args).and_return(plan)
      allow(tier).to receive(:previous).once.with(no_args).and_return(previous)

      subscription.unsubscribe(repo_id)

      expect(stripe_subscription).to be_saved
      expect(stripe_subscription.metadata).to eq("repo_ids" => nil)
      expect(stripe_subscription.plan).to eq plan
    end
  end

  class MockStripeSubscription
    attr_accessor :quantity, :metadata, :plan

    def initialize(repo_ids:)
      @quantity = repo_ids.count
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
      @quantity = 1
      @metadata = { "repo_id" => repo_id.to_s }
    end
  end
end
