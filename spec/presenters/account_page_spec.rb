require "rails_helper"

RSpec.describe AccountPage do
  describe "#allowance" do
    it "returns the allowance of the current tier" do
      allowance = 10
      pricing = instance_double("Pricing", allowance: allowance)
      tier = instance_double("Tier", current: pricing)
      user = instance_double("User")
      page = AccountPage.new(user)
      allow(Tier).to receive(:new).once.with(user).and_return(tier)

      expect(page.allowance).to eq allowance
    end
  end

  describe "#billable_email" do
    it "returns the user's billable email" do
      billable_email = "somebody@example.com"
      user = instance_double("User", billable_email: billable_email)
      page = AccountPage.new(user)

      expect(page.billable_email).to eq billable_email
    end
  end

  describe "#monthly_line_item" do
    it "returns the subscription as a monthly line item" do
      subscription = instance_double("PaymentGatewaySubscription")
      user = instance_double("User", payment_gateway_subscription: subscription)
      page = AccountPage.new(user)

      expect(page.monthly_line_item).to eq MonthlyLineItem.new(subscription)
    end
  end

  describe "#plan" do
    it "returns the name of the current tier" do
      plan = "Chihuahua"
      pricing = instance_double("Pricing", title: plan)
      tier = instance_double("Tier", current: pricing)
      user = instance_double("User")
      page = AccountPage.new(user)
      allow(Tier).to receive(:new).once.with(user).and_return(tier)

      expect(page.plan).to eq plan
    end
  end

  describe "#pricings" do
    it "returns all of the presentable, available pricings" do
      presenter = instance_double("PricingPresenter")
      pricing = instance_double("Pricing")
      user = instance_double("User")
      page = AccountPage.new(user)
      allow(Pricing).to receive(:all).once.with(no_args).and_return([pricing])
      allow(PricingPresenter).to receive(:new).once.with(
        pricing: pricing,
        user: user,
      ).and_return(presenter)

      expect(page.pricings).to eq [presenter]
    end
  end

  describe "#remaining" do
    it "returns the number of remaining repos available in the current tier" do
      pricing = instance_double("Pricing", allowance: 10)
      remaining = 9
      repos = class_double("Repo", count: 1)
      tier = instance_double("Tier", current: pricing)
      user = instance_double("User", subscribed_repos: repos)
      page = AccountPage.new(user)
      allow(Tier).to receive(:new).once.with(user).and_return(tier)

      expect(page.remaining).to eq remaining
    end
  end

  describe "#repos" do
    it "returns the subscriped repos ordered by name" do
      ordered_repos = instance_double("Repo")
      subscribed_repos = class_double("Repo")
      user = instance_double("User", subscribed_repos: subscribed_repos)
      page = AccountPage.new(user)
      allow(subscribed_repos).to receive(:order).once.with(:name).
        and_return(ordered_repos)

      expect(page.repos).to eq ordered_repos
    end
  end

  describe "#subscription" do
    it "returns the user's payment gateway subscription" do
      subscription = instance_double("PaymentGatewaySubscription")
      user = instance_double("User", payment_gateway_subscription: subscription)
      page = AccountPage.new(user)

      expect(page.subscription).to eq subscription
    end
  end

  describe "#total_monthly_cost" do
    it "returns the subtotal of the monthly line item in dollars" do
      cost = 200.00
      item = instance_double("MonthlyLineItem", subtotal_in_dollars: cost)
      subscription = instance_double("PaymentGatewaySubscription")
      user = instance_double("User", payment_gateway_subscription: subscription)
      page = AccountPage.new(user)
      allow(MonthlyLineItem).to receive(:new).once.with(subscription).
        and_return(item)

      expect(page.total_monthly_cost).to eq cost
    end
  end
end
