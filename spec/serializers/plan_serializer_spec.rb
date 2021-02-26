require "active_model_serializers"

require "app/models/plan"
require "app/models/metered_stripe_plan"
require "app/serializers/plan_serializer"

RSpec.describe PlanSerializer do
  describe "#as_json" do
    it "returns the plan as a JSON object" do
      allowance = 0
      price = 0
      title = "Hound"
      plan = MeteredStripePlan.new(id: "foo", title: title, range: 0..0, price: price)
      user = instance_double("User", current_plan: plan)
      serializer = PlanSerializer.new(plan, root: false, scope: user)

      expect(serializer.as_json).to eq(
        current: true,
        name: title,
        price: price,
        allowance: allowance,
      )
    end
  end
end
