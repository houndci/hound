# frozen_string_literal: true

require "spec_helper"
require "active_model/serializer_support"
require "app/models/plan"
require "app/presenters/plan_presenter"
require "app/models/home"

RSpec.describe Home do
  describe "#open_source_plans" do
    it "returns all the presented plans that are open source" do
      open_source_plan = instance_double("Plan", open_source?: true)
      presenter = instance_double("PlanPresenter")
      private_plan = instance_double("Plan", open_source?: false)
      plans = [open_source_plan, private_plan]
      user = instance_double("User")
      home = Home.new(user)
      allow(Plan).to receive(:all).and_return(plans)
      allow(PlanPresenter).to receive(:new).and_return(presenter)

      expect(home.open_source_plans).to eq [presenter]
      expect(Plan).to have_received(:all).once.with(no_args)
      expect(PlanPresenter).to have_received(:new).once.with(
        plan: open_source_plan,
        user: user,
      )
    end
  end

  describe "#private_plans" do
    it "returns all the presented plans that are not open source" do
      open_source_plan = instance_double("Plan", open_source?: true)
      presenter = instance_double("PlanPresenter")
      private_plan = instance_double("Plan", open_source?: false)
      plans = [open_source_plan, private_plan]
      user = instance_double("User")
      home = Home.new(user)
      allow(Plan).to receive(:all).and_return(plans)
      allow(PlanPresenter).to receive(:new).and_return(presenter)

      expect(home.private_plans).to eq [presenter]
      expect(Plan).to have_received(:all).once.with(no_args)
      expect(PlanPresenter).to have_received(:new).once.with(
        plan: private_plan,
        user: user,
      )
    end
  end
end
