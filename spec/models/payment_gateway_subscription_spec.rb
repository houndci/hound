# frozen_string_literal: true

require "rails_helper"

describe PaymentGatewaySubscription do
  describe "#subscribe" do
    it "sets the plan to the upgraded tier" do
      plan_id = "tier1"
      repo_id = 1
      stripe_subscription = MockStripeSubscription.new(repo_ids: ["1"])
      next_plan = instance_double("Plan", id: plan_id)
      user = instance_double("User", next_plan: next_plan)
      subscription = PaymentGatewaySubscription.new(
        stripe_subscription: stripe_subscription,
        user: user,
      )

      subscription.subscribe(repo_id)

      expect(stripe_subscription).to be_saved
      expect(stripe_subscription.metadata).to eq("repo_ids" => repo_id.to_s)
      expect(stripe_subscription.plan).to eq plan_id
    end
  end

  describe "#unsubscribe" do
    it "sets the plan to the downgraded tier" do
      plan_id = "basic"
      repo_id = 1
      stripe_subscription = MockStripeSubscription.new(repo_ids: [repo_id])
      plan = instance_double("Plan", id: plan_id)
      user = instance_double("User", previous_plan: plan)
      subscription = PaymentGatewaySubscription.new(
        stripe_subscription: stripe_subscription,
        user: user,
      )

      subscription.unsubscribe(repo_id)

      expect(stripe_subscription).to be_saved
      expect(stripe_subscription.metadata).to eq("repo_ids" => nil)
      expect(stripe_subscription.plan).to eq plan_id
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
