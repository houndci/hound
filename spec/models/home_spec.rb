require "spec_helper"
require "active_model/serialization"
require "app/models/plan"
require "app/presenters/plan_presenter"
require "app/models/home"
require "app/models/plan_selector"
require "app/models/github_plan"

RSpec.describe Home do
  describe "#open_source_plans" do
    it "returns all the presented plans that are open source" do
      open_source_plan = instance_double(
        "MeteredStripePlan",
        open_source?: true,
      )
      presenter = instance_double("PlanPresenter")
      private_plan = instance_double("MeteredStripePlan", open_source?: false)
      plans = [open_source_plan, private_plan]
      user = instance_double("User")
      home = Home.new(user)
      plan_selector = instance_double("PlanSelector", plans: plans)
      allow(PlanSelector).to receive(:new).and_return(plan_selector)
      allow(PlanPresenter).to receive(:new).and_return(presenter)

      expect(home.open_source_plans).to eq [presenter]
      expect(PlanPresenter).to have_received(:new).once.with(
        plan: open_source_plan,
        user: user,
      )
      expect(PlanSelector).to have_received(:new).once.with(
        user: user,
      )
    end
  end

  describe "#private_plans" do
    it "returns all the presented plans that are not open source" do
      open_source_plan = instance_double(
        "MeteredStripePlan",
        open_source?: true,
      )
      presenter = instance_double("PlanPresenter")
      private_plan = instance_double("MeteredStripePlan", open_source?: false)
      plans = [open_source_plan, private_plan]
      user = instance_double("User")
      home = Home.new(user)
      plan_selector = instance_double("PlanSelector", plans: plans)
      allow(PlanSelector).to receive(:new).and_return(plan_selector)
      allow(PlanPresenter).to receive(:new).and_return(presenter)

      expect(home.private_plans).to eq [presenter]
      expect(PlanPresenter).to have_received(:new).once.with(
        plan: private_plan,
        user: user,
      )
      expect(PlanSelector).to have_received(:new).once.with(
        user: user,
      )
    end
  end
end
