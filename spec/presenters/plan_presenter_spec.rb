require "rails_helper"

RSpec.describe PlanPresenter do
  describe "#allowance" do
    it "returns the plan's allowance" do
      user = create(:user)
      plan = build_stubbed(:plan)
      presenter = PlanPresenter.new(plan: plan, user: user)

      expect(presenter.allowance).to eq plan.allowance
    end
  end

  describe "#current?" do
    context "when the plan matches the user's current plan" do
      it "returns true" do
        user = create(:user)
        create(:owner, name: user.username)
        plan = StripePlan.new(**StripePlan::PLANS.first)
        presenter = PlanPresenter.new(plan: plan, user: user)

        expect(presenter).to be_current
      end
    end

    context "when the plan does not match the user's current plan" do
      it "returns false" do
        user = create(:user)
        create(:owner, name: user.username)
        plan = StripePlan.new(**StripePlan::PLANS.second)
        presenter = PlanPresenter.new(plan: plan, user: user)

        expect(presenter).to_not be_current
      end
    end
  end

  describe "#next?" do
    context "when the plan matches the user's next plan" do
      it "returns true" do
        user = create(:user)
        create(:owner, name: user.username)
        plan = StripePlan.new(**StripePlan::PLANS.second)
        presenter = PlanPresenter.new(plan: plan, user: user)

        expect(presenter).to be_next
      end
    end

    context "when the plan does not match the user's next plan" do
      it "returns false" do
        membership = create(:membership)
        user = membership.user
        create(:owner, name: user.username)
        plan = StripePlan.new(**StripePlan::PLANS[2])
        presenter = PlanPresenter.new(plan: plan, user: user)

        expect(presenter).to_not be_next
      end
    end
  end

  describe "#open_source?" do
    it "returns the plan's open source state" do
      user = instance_double("User")
      plan = instance_double("StripePlan", open_source?: true)
      presenter = PlanPresenter.new(plan: plan, user: user)

      expect(presenter).to be_open_source
    end
  end

  describe "#price" do
    it "returns the plan's price" do
      user = instance_double("User")
      plan = instance_double("StripePlan", price: 123)
      presenter = PlanPresenter.new(plan: plan, user: user)

      expect(presenter.price).to eq plan.price
    end
  end

  describe "#to_partial_path" do
    context "when the plan is for open source repos" do
      it "returns 'plans/open_source'" do
        user = instance_double("User")
        plan = instance_double("StripePlan", open_source?: true)
        presenter = PlanPresenter.new(plan: plan, user: user)

        expect(presenter.to_partial_path).to eq("plans/open_source")
      end
    end

    context "when the plan is for private repos" do
      it "returns 'plans/private'" do
        user = instance_double("User")
        plan = instance_double("StripePlan", open_source?: false)
        presenter = PlanPresenter.new(plan: plan, user: user)

        expect(presenter.to_partial_path).to eq("plans/private")
      end
    end
  end

  describe "#title" do
    it "returns the plan's title" do
      user = instance_double("User")
      plan = instance_double("StripePlan", title: "Foo Plan")
      presenter = PlanPresenter.new(plan: plan, user: user)

      expect(presenter.title).to eq plan.title
    end
  end
end
