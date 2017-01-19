require "spec_helper"
require "active_model/serializer_support"
require "app/models/pricing"

RSpec.describe Pricing do
  describe ".all" do
    it "returns all of the pricings" do
      pricings = Pricing.all

      expect(pricings.count).to eq 4

      [
        [0, "basic", 0, "Hound"],
        [4, "tier1", 49, "Chihuahua"],
        [10, "tier2", 99, "Labrador"],
        [30, "tier3", 249, "Great Dane"],
      ].each_with_index do |(allowance, id, price, title), index|
        expect(pricings[index].allowance).to eq allowance
        expect(pricings[index].id).to eq id
        expect(pricings[index].price).to eq price
        expect(pricings[index].title).to eq title
      end
    end
  end

  describe ".find_by" do
    it "returns the pricing where the count is in range" do
      pricing = Pricing.find_by(count: 7)

      expect(pricing.allowance).to eq 10
      expect(pricing.id).to eq "tier2"
      expect(pricing.price).to eq 99
      expect(pricing.title).to eq "Labrador"
    end
  end

  describe "#==" do
    context "when the pricings have the same identifiers" do
      it "returns true" do
        allowance = 4
        id = "tier1"
        price = 49
        range = 1..allowance
        title = "Chihuahua"
        pricing_1 = Pricing.new(
          id: id,
          price: price,
          range: range,
          title: title,
        )
        pricing_2 = Pricing.new(
          id: id,
          price: price,
          range: range,
          title: title,
        )

        expect(pricing_1).to eq(pricing_2)
      end
    end

    context "when the pricings have different identifiers" do
      it "returns false" do
        allowance = 4
        id = "tier1"
        price = 49
        range = 1..allowance
        title = "Chihuahua"
        pricing_1 = Pricing.new(
          id: id,
          price: price,
          range: range,
          title: title,
        )
        pricing_2 = Pricing.new(
          id: "tier2",
          price: price,
          range: range,
          title: title,
        )

        expect(pricing_1).to_not eq(pricing_2)
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
      pricing = Pricing.new(id: id, price: price, range: range, title: title)

      expect(pricing.allowance).to eq allowance
    end
  end

  describe "#id" do
    it "returns the initialized identifier" do
      allowance = 4
      id = "tier1"
      price = 49
      range = 1..allowance
      title = "Chihuahua"
      pricing = Pricing.new(id: id, price: price, range: range, title: title)

      expect(pricing.id).to eq id
    end
  end

  describe "#open_source?" do
    it "returns true" do
      pricing = Pricing.new(
        id: "basic",
        price: 0,
        range: 0..0,
        title: "Hound",
      )

      expect(pricing).to be_open_source
    end

    context "when the price is positive" do
      it "returns false" do
        pricing = Pricing.new(
          id: "tier1",
          price: 49,
          range: 1..4,
          title: "Chihuahua",
        )

        expect(pricing).to_not be_open_source
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
      pricing = Pricing.new(id: id, price: price, range: range, title: title)

      expect(pricing.price).to eq price
    end
  end

  describe "#title" do
    it "returns the initialized title" do
      allowance = 4
      id = "tier1"
      price = 49
      range = 1..allowance
      title = "Chihuahua"
      pricing = Pricing.new(id: id, price: price, range: range, title: title)

      expect(pricing.title).to eq title
    end
  end
end
