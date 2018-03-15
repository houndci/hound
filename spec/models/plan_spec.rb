# frozen_string_literal: true

require "active_model/serialization"

require "app/models/plan"

RSpec.describe Plan do
  describe ".all" do
    it "returns all of the plans" do
      plans = Plan.all

      expect(plans.count).to eq 4

      [
        [0, "basic", 0, "Hound"],
        [4, "tier1", 49, "Chihuahua"],
        [10, "tier2", 99, "Labrador"],
        [30, "tier3", 249, "Great Dane"],
      ].each_with_index do |(allowance, id, price, title), index|
        expect(plans[index].allowance).to eq allowance
        expect(plans[index].id).to eq id
        expect(plans[index].price).to eq price
        expect(plans[index].title).to eq title
      end
    end
  end

  describe ".find_by" do
    it "returns the plan where the count is in range" do
      plan = Plan.find_by(count: 7)

      expect(plan.allowance).to eq 10
      expect(plan.id).to eq "tier2"
      expect(plan.price).to eq 99
      expect(plan.title).to eq "Labrador"
    end
  end

  describe "#==" do
    context "when the plans have the same identifiers" do
      it "returns true" do
        allowance = 4
        id = "tier1"
        price = 49
        range = 1..allowance
        title = "Chihuahua"
        plan1 = Plan.new(
          id: id,
          price: price,
          range: range,
          title: title,
        )
        plan2 = Plan.new(
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
        plan1 = Plan.new(
          id: id,
          price: price,
          range: range,
          title: title,
        )
        plan2 = Plan.new(
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
      plan = Plan.new(id: id, price: price, range: range, title: title)

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
      plan = Plan.new(id: id, price: price, range: range, title: title)

      expect(plan.id).to eq id
    end
  end

  describe "#open_source?" do
    it "returns true" do
      plan = Plan.new(
        id: "basic",
        price: 0,
        range: 0..0,
        title: "Hound",
      )

      expect(plan).to be_open_source
    end

    context "when the price is positive" do
      it "returns false" do
        plan = Plan.new(
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
      plan = Plan.new(id: id, price: price, range: range, title: title)

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
      plan = Plan.new(id: id, price: price, range: range, title: title)

      expect(plan.title).to eq title
    end
  end
end
