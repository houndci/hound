require "rails_helper"

RSpec.describe AccountPage do
  describe "#allowance" do
    it "returns the allowance of the current plan" do
      allowance = 10
      plan = instance_double("StripePlan", allowance: allowance)
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
      plan = instance_double("StripePlan", title: plan_name)
      user = instance_double("User", current_plan: plan)
      page = AccountPage.new(user)

      expect(page.plan).to eq plan_name
    end
  end

  describe "#plans" do
    it "returns all of the presentable, available plans" do
      presenter = instance_double("PlanPresenter")
      plan = instance_double("StripePlan")
      owner = instance_double("Owner")
      user = instance_double("User", owner: owner)
      page = AccountPage.new(user)
      plan_selector = instance_double("PlanSelector", plans: [plan])
      allow(PlanSelector).to receive(:new).once.with(owner).
        and_return(plan_selector)
      allow(PlanPresenter).to receive(:new).once.with(plan: plan, user: user).
        and_return(presenter)

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
