require "rails_helper"

RSpec.describe PricingPresenter do
  describe "#allowance" do
    it "returns the pricing's allowance" do
      user = create(:user)
      pricing = build_stubbed(:pricing)
      presenter = PricingPresenter.new(pricing: pricing, user: user)

      expect(presenter.allowance).to eq pricing.allowance
    end
  end

  describe "#current?" do
    context "when the pricing matches the user's current pricing" do
      it "returns true" do
        membership = create(:membership)
        user = membership.user
        create(:subscription, repo: membership.repo, user: user)
        pricing = build_stubbed(:pricing)
        presenter = PricingPresenter.new(pricing: pricing, user: user)

        expect(presenter).to be_current
      end
    end

    context "when the pricing does not match the user's current pricing" do
      it "returns false" do
        membership = create(:membership)
        user = membership.user
        create(:subscription, repo: membership.repo, user: user)
        pricing = build_stubbed(:pricing, :tier2)
        presenter = PricingPresenter.new(pricing: pricing, user: user)

        expect(presenter).to_not be_current
      end
    end
  end

  describe "#next?" do
    context "when the pricing matches the user's next pricing" do
      it "returns true" do
        membership = create(:membership)
        user = membership.user
        create(:subscription, repo: membership.repo, user: user)
        pricing = build_stubbed(:pricing)
        presenter = PricingPresenter.new(pricing: pricing, user: user)

        expect(presenter).to be_next
      end
    end

    context "when the pricing does not match the user's next pricing" do
      it "returns false" do
        membership = create(:membership)
        user = membership.user
        create(:subscription, repo: membership.repo, user: user)
        pricing = build_stubbed(:pricing, :tier2)
        presenter = PricingPresenter.new(pricing: pricing, user: user)

        expect(presenter).to_not be_next
      end
    end
  end

  describe "#open_source?" do
    it "returns the pricing's open source state" do
      pricing = instance_double("Pricing", open_source?: true)
      user = instance_double("User")
      presenter = PricingPresenter.new(pricing: pricing, user: user)

      expect(presenter).to be_open_source
    end
  end

  describe "#price" do
    it "returns the pricing's price" do
      user = create(:user)
      pricing = build_stubbed(:pricing)
      presenter = PricingPresenter.new(pricing: pricing, user: user)

      expect(presenter.price).to eq pricing.price
    end
  end

  describe "#to_partial_path" do
    context "when the pricing is for open source repos" do
      it "returns 'pricings/open_source'" do
        pricing = instance_double("Pricing", open_source?: true)
        user = instance_double("User")
        presenter = PricingPresenter.new(pricing: pricing, user: user)

        expect(presenter.to_partial_path).to eq("pricings/open_source")
      end
    end

    context "when the pricing is for private repos" do
      it "returns 'pricings/private'" do
        pricing = instance_double("Pricing", open_source?: false)
        user = instance_double("User")
        presenter = PricingPresenter.new(pricing: pricing, user: user)

        expect(presenter.to_partial_path).to eq("pricings/private")
      end
    end
  end

  describe "#title" do
    it "returns the pricing's title" do
      user = create(:user)
      pricing = build_stubbed(:pricing)
      presenter = PricingPresenter.new(pricing: pricing, user: user)

      expect(presenter.title).to eq pricing.title
    end
  end
end
