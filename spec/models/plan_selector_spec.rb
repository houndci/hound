require "active_model/serialization"

require "app/models/plan"
require "app/models/stripe_plan"
require "app/models/github_plan"
require "app/models/plan_selector"

RSpec.describe PlanSelector do
  describe "#current_plan" do
    it "returns owner's current plan" do
      plan = StripePlan::PLANS[1]
      payment_gateway = instance_double(
        "PaymentGatewaySubscription",
        plan: plan[:id],
      )
      owner = build_owner(payment_gateway_subscription: payment_gateway)
      user = instance_double("User")
      repo = instance_double("Repo", owner: owner)
      plan_selector = PlanSelector.new(user: user, repo: repo)

      actual = plan_selector.current_plan

      expect(actual).to eq StripePlan.new(plan)
    end
  end

  describe "#upgrade?" do
    context "when owner is subscribed via Stripe" do
      context "when the owner isn't subsribed to any plan" do
        it "returns true" do
          payment_gateway = instance_double(
            "PaymentGatewaySubscription",
            plan: nil
          )
          owner = build_owner(payment_gateway_subscription: payment_gateway)
          user = instance_double("User")
          repo = instance_double("Repo", owner: owner)
          plan_selector = PlanSelector.new(user: user, repo: repo)

          actual = plan_selector.upgrade?

          expect(actual).to eq true
        end
      end

      context "when recent builds is greater or equal than plan allowance" do
        it "returns true" do
          owner = build_owner(recent_builds: 50)
          repo = instance_double("Repo", owner: owner)
          user = instance_double("User")
          plan_selector = PlanSelector.new(user: user, repo: repo)

          actual = plan_selector.upgrade?

          expect(actual).to eq true
        end
      end

      context "recent builds is less than plan allowance" do
        it "returns false" do
          owner = build_owner(recent_builds: 49)
          repo = instance_double("Repo", owner: owner)
          user = instance_double("User")
          plan_selector = PlanSelector.new(user: user, repo: repo)

          actual = plan_selector.upgrade?

          expect(actual).to eq false
        end
      end
    end

    context "when owner is subscribed via GitHub Marketplace" do
      [
        { current_plan: 0, repos: 0, expected: true },
        { current_plan: 1, repos: 3, expected: false },
        { current_plan: 1, repos: 4, expected: true },
        { current_plan: 2, repos: 5, expected: false },
        { current_plan: 2, repos: 19, expected: false },
        { current_plan: 2, repos: 20, expected: true },
      ].each do |test_data|
        context "when account has #{test_data[:repos]} private repos" do
          it "returns #{test_data[:expected]}" do
            current_plan = GitHubPlan::PLANS[test_data[:current_plan]]
            owner = instance_double(
              "Owner",
              marketplace_plan_id: current_plan[:id],
              active_private_repos_count: test_data[:repos],
            )
            repo = instance_double("Repo", owner: owner)
            user = instance_double("User")
            plan_selector = described_class.new(user: user, repo: repo)

            actual = plan_selector.upgrade?

            expect(actual).to eq(test_data[:expected])
          end
        end
      end
    end
  end

  describe "#next_plan" do
    context "when the owner has no subscribed repos" do
      it "returns the first paid plan" do
        owner = instance_double("Owner")
        user = instance_double("User", first_active_private_repo: nil)
        repo = instance_double("Repo", owner: owner)
        plan_selector = PlanSelector.new(user: user)

        actual = plan_selector.next_plan

        expect(actual).to eq StripePlan.new(**StripePlan::PLANS[1])
      end
    end

    context "when the user has maxed out recent builds" do
      it "returns the next paid plan" do
        owner = build_owner(recent_builds: 55)
        repo = instance_double("Repo", owner: owner)
        user = instance_double("User", first_active_private_repo: repo)
        plan_selector = PlanSelector.new(user: user)

        actual = plan_selector.next_plan

        expect(actual).to eq StripePlan.new(**StripePlan::PLANS[2])
      end
    end
  end

  def build_owner(options = {})
    plan = StripePlan::PLANS[1]
    payment_gateway_subscription = instance_double(
      "PaymentGatewaySubscription",
      plan: plan[:id],
    )
    default_options = {
      recent_builds: 0,
      marketplace_plan_id: nil,
      payment_gateway_subscription: payment_gateway_subscription,
    }

    instance_double("Owner", default_options.merge(options))
  end
end
