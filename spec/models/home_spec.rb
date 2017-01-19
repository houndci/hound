require "spec_helper"
require "active_model/serializer_support"
require "app/models/pricing"
require "app/presenters/pricing_presenter"
require "app/models/home"

RSpec.describe Home do
  describe "#open_source_pricings" do
    it "returns all the presented pricings that are open source" do
      open_source_pricing = instance_double("Pricing", open_source?: true)
      presenter = instance_double("PricingPresenter")
      private_pricing = instance_double("Pricing", open_source?: false)
      pricings = [open_source_pricing, private_pricing]
      user = instance_double("User")
      home = Home.new(user)
      allow(Pricing).to receive(:all).and_return(pricings)
      allow(PricingPresenter).to receive(:new).and_return(presenter)

      expect(home.open_source_pricings).to eq [presenter]
      expect(Pricing).to have_received(:all).once.with(no_args)
      expect(PricingPresenter).to have_received(:new).once.with(
        pricing: open_source_pricing,
        user: user,
      )
    end
  end

  describe "#private_pricings" do
    it "returns all the presented pricings that are not open source" do
      open_source_pricing = instance_double("Pricing", open_source?: true)
      presenter = instance_double("PricingPresenter")
      private_pricing = instance_double("Pricing", open_source?: false)
      pricings = [open_source_pricing, private_pricing]
      user = instance_double("User")
      home = Home.new(user)
      allow(Pricing).to receive(:all).and_return(pricings)
      allow(PricingPresenter).to receive(:new).and_return(presenter)

      expect(home.private_pricings).to eq [presenter]
      expect(Pricing).to have_received(:all).once.with(no_args)
      expect(PricingPresenter).to have_received(:new).once.with(
        pricing: private_pricing,
        user: user,
      )
    end
  end
end
