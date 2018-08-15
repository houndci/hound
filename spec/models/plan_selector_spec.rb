require "active_model/serialization"

require "app/models/plan"
require "app/models/github_plan"
require "app/models/plan_selector"

RSpec.describe PlanSelector do
  describe "#current_plan" do
    it "returns user's current plan" do
      user = instance_double(
        "User",
        subscribed_repos: [double],
        marketplace_subscriber?: false
      )
      plan_selector = PlanSelector.new(user)

      expect(plan_selector.current_plan).to eq Plan.new(Plan::PLANS[1])
    end
  end

  describe "#upgrade?" do
    context "when the next plan is different to the current plan" do
      it "returns true" do
        user = instance_double(
          "User",
          subscribed_repos: Array.new(4) { double },
          marketplace_subscriber?: false,
        )
        plan_selector = PlanSelector.new(user)

        expect(plan_selector).to be_upgrade
      end
    end

    context "when the user has no repos" do
      it "returns true" do
        user = instance_double(
          "User",
          subscribed_repos: [],
          marketplace_subscriber?: false,
        )
        plan_selector = PlanSelector.new(user)

        expect(plan_selector).to be_upgrade
      end
    end

    context "when the next plan is not the same as the current plan" do
      it "returns false" do
        user = instance_double(
          "User",
          subscribed_repos: Array.new(3) { double },
          marketplace_subscriber?: false,
        )
        plan_selector = PlanSelector.new(user)

        expect(plan_selector).not_to be_upgrade
      end
    end
  end

  describe "#next_plan" do
    context "when the user has no subscribed repos" do
      it "returns the first paid plan" do
        user = instance_double(
          "User",
          subscribed_repos: [],
          marketplace_subscriber?: false,
        )
        plan_selector = PlanSelector.new(user)

        expect(plan_selector.next_plan).to eq Plan.new(Plan::PLANS[1])
      end
    end
  end

  describe "#previous_plan" do
    it "returns the second paid plan" do
      user = instance_double(
        "User",
        subscribed_repos: Array.new(10) { double },
        marketplace_subscriber?: false,
      )
      plan_selector = PlanSelector.new(user)

      expect(plan_selector.previous_plan).to eq Plan.new(Plan::PLANS[2])
    end
  end
end
