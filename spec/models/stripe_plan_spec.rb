require "active_model/serialization"

require "app/models/plan"
require "app/models/stripe_plan"

RSpec.describe StripePlan do
  describe "#==" do
    context "when the plans have the same identifiers" do
      it "returns true" do
        allowance = 4
        id = "tier1"
        price = 49
        range = 1..allowance
        title = "Chihuahua"
        plan1 = StripePlan.new(
          id: id,
          price: price,
          range: range,
          title: title,
        )
        plan2 = StripePlan.new(
          id: id,
          price: price,
          range: range,
          title: title,
        )

        expect(plan1).to eq(plan2)
      end
    end

    context "when the plans have different identifiers" do
      it "returns false" do
        allowance = 4
        id = "tier1"
        price = 49
        range = 1..allowance
        title = "Chihuahua"
        plan1 = StripePlan.new(
          id: id,
          price: price,
          range: range,
          title: title,
        )
        plan2 = StripePlan.new(
          id: "tier2",
          price: price,
          range: range,
          title: title,
        )

        expect(plan1).to_not eq(plan2)
      end
    end
  end

  describe "#allowance" do
    it "returns the upper bound of the range" do
      allowance = 4
      id = "tier1"
      price = 49
      range = 1..allowance
      title = "Chihuahua"
      plan = StripePlan.new(id: id, price: price, range: range, title: title)

      expect(plan.allowance).to eq allowance
    end
  end

  describe "#id" do
    it "returns the initialized identifier" do
      allowance = 4
      id = "tier1"
      price = 49
      range = 1..allowance
      title = "Chihuahua"
      plan = StripePlan.new(id: id, price: price, range: range, title: title)

      expect(plan.id).to eq id
    end
  end

  describe "#open_source?" do
    it "returns true" do
      plan = StripePlan.new(
        id: "basic",
        price: 0,
        range: 0..0,
        title: "Hound",
      )

      expect(plan).to be_open_source
    end

    context "when the price is positive" do
      it "returns false" do
        plan = StripePlan.new(
          id: "tier1",
          price: 49,
          range: 1..4,
          title: "Chihuahua",
        )

        expect(plan).to_not be_open_source
      end
    end
  end

  describe "#price" do
    it "returns the initialized price" do
      allowance = 4
      id = "tier1"
      price = 49
      range = 1..allowance
      title = "Chihuahua"
      plan = StripePlan.new(id: id, price: price, range: range, title: title)

      expect(plan.price).to eq price
    end
  end

  describe "#title" do
    it "returns the initialized title" do
      allowance = 4
      id = "tier1"
      price = 49
      range = 1..allowance
      title = "Chihuahua"
      plan = StripePlan.new(id: id, price: price, range: range, title: title)

      expect(plan.title).to eq title
    end
  end
end
