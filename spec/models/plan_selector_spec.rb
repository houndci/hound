require "active_model/serialization"

require "app/models/plan"
require "app/models/stripe_plan"
require "app/models/github_plan"
require "app/models/metered_stripe_plan"
require "app/models/plan_selector"

RSpec.describe PlanSelector do
  describe "#current_plan" do
    it "returns user's current plan" do
      user = instance_double(
        "User",
        subscribed_repos: [double],
        metered_plan?: false,
      )
      repo = instance_double(
        "Repo",
        owner: double.as_null_object,
      )
      plan_selector = PlanSelector.new(user: user, repo: repo)

      expect(plan_selector.current_plan).
        to eq StripePlan.new(**StripePlan::PLANS[1])
    end
  end

  describe "#upgrade?" do
    context "user is a Stripe subscriber" do
      context "when the next plan is different to the current plan" do
        it "returns true" do
          user = instance_double(
            "User",
            subscribed_repos: Array.new(4) { double },
            metered_plan?: false,
          )
          repo = instance_double(
            "Repo",
            owner: double.as_null_object,
          )
          plan_selector = PlanSelector.new(user: user, repo: repo)

          expect(plan_selector).to be_upgrade
        end
      end

      context "when the user has no repos" do
        it "returns true" do
          user = instance_double(
            "User",
            subscribed_repos: [],
            first_available_repo: double.as_null_object,
            metered_plan?: false,
          )
          plan_selector = PlanSelector.new(user: user, repo: nil)

          expect(plan_selector).to be_upgrade
        end
      end

      context "when the next plan is not the same as the current plan" do
        it "returns false" do
          user = instance_double(
            "User",
            subscribed_repos: Array.new(3) { double },
            metered_plan?: false,
          )
          repo = instance_double(
            "Repo",
            owner: double.as_null_object,
          )
          plan_selector = PlanSelector.new(user: user, repo: repo)

          expect(plan_selector).not_to be_upgrade
        end
      end
    end

    context "user is a GitHub Marketplace subscriber" do
      [
        { current_plan: 0, repos: 0, expected: true },
        { current_plan: 1, repos: 3, expected: false },
        { current_plan: 1, repos: 4, expected: true },
        { current_plan: 2, repos: 5, expected: false },
        { current_plan: 2, repos: 19, expected: false },
        { current_plan: 2, repos: 20, expected: false },
      ].each do |test_data|
        context "when account has #{test_data[:repos]} private repos" do
          it "returns #{test_data[:expected]}" do
            current_plan = GitHubPlan::PLANS[test_data[:current_plan]]
            owner = instance_double(
              "Owner",
              marketplace_plan_id: current_plan[:id],
            )
            repo = instance_double("Repo", owner: owner)
            user = instance_double(
              "User",
              subscribed_repos: double(size: test_data[:repos]),
              metered_plan?: false,
            )
            plan_selector = described_class.new(user: user, repo: repo)

            expect(plan_selector.upgrade?).to eq(test_data[:expected])
          end
        end
      end
    end

    context "user is a MeteredStripe subscriber" do
      context "when the current plan is open source (free)" do
        it "returns true" do
          user = instance_double(
            "User",
            subscribed_repos: Array.new(1) { double },
            metered_plan?: true,
            payment_gateway_subscription: double(
              plan: MeteredStripePlan::PLANS[0]["id"]
            )
          )
          repo = instance_double(
            "Repo",
            owner: double.as_null_object,
          )
          plan_selector = PlanSelector.new(user: user, repo: repo)

          expect(plan_selector).to be_upgrade
        end
      end
    end
  end

  describe "#next_plan" do
    context "when the user has no subscribed repos" do
      it "returns the first paid plan" do
        user = instance_double(
          "User",
          subscribed_repos: [],
          first_available_repo: double.as_null_object,
          metered_plan?: false,
        )
        plan_selector = PlanSelector.new(user: user, repo: nil)

        expect(plan_selector.next_plan).
          to eq StripePlan.new(**StripePlan::PLANS[1])
      end
    end
  end

  describe "#previous_plan" do
    it "returns the second paid plan" do
      user = instance_double(
        "User",
        subscribed_repos: Array.new(10) { double },
        metered_plan?: false,
      )
      repo = instance_double(
        "Repo",
        owner: double.as_null_object,
      )
      plan_selector = PlanSelector.new(user: user, repo: repo)

      expect(plan_selector.previous_plan).
        to eq StripePlan.new(StripePlan::PLANS[2])
    end
  end
end
