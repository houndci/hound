require "spec_helper"
require "active_model/serializer"
require "app/serializers/pricing_serializer"

RSpec.describe PricingSerializer do
  describe "#as_json" do
    it "returns the pricing as a JSON object" do
      allowance = 0
      price = 0
      title = "Hound"
      pricing = instance_double("Pricing", title: title)
      tier = instance_double("Tier")
      user = instance_double("User", current_tier: tier)
      serializer = PricingSerializer.new(pricing, root: false, scope: user)
      allow(pricing).to receive(:read_attribute_for_serialization).once.
        with(:allowance).and_return(allowance)
      allow(pricing).to receive(:read_attribute_for_serialization).once.
        with(:price).and_return(price)

      expect(serializer.as_json).to eq(
        current: false,
        name: title,
        price: price,
        allowance: allowance,
      )
    end
  end
end
