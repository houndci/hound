require "rails_helper"

RSpec.describe AccountPage do
  describe "#allowance" do
    it "returns the allowance of the current plan" do
      allowance = 10
      plan = instance_double("Plan", allowance: allowance)
      user = instance_double("User", current_plan: plan)
      page = AccountPage.new(user)

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
    it "returns the name of the current plan" do
      plan_name = "Chihuahua"
      plan = instance_double("Plan", title: plan_name)
      user = instance_double("User", current_plan: plan)
      page = AccountPage.new(user)

      expect(page.plan).to eq plan_name
    end
  end

  describe "#plans" do
    it "returns all of the presentable, available plans" do
      presenter = instance_double("PlanPresenter")
      plan = instance_double("Plan")
      user = instance_double("User")
      page = AccountPage.new(user)
      allow(Plan).to receive(:all).once.with(no_args).and_return([plan])
      allow(PlanPresenter).to receive(:new).once.with(
        plan: plan,
        user: user,
      ).and_return(presenter)

      expect(page.plans).to eq [presenter]
    end
  end

  describe "#remaining" do
    it "returns the number of remaining repos available in the current plan" do
      plan = instance_double("Plan", allowance: 10)
      remaining = 9
      repos = class_double("Repo", count: 1)
      user = instance_double(
        "User",
        current_plan: plan,
        subscribed_repos: repos,
      )
      page = AccountPage.new(user)

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
