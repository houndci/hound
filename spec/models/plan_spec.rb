require "fast_spec_helper"
require "app/models/plan"

describe Plan do
  describe "#type" do
    context "with public repo" do
      it "returns public" do
        public_repo = double("Repo", private?: false)
        plan = Plan.new(public_repo)

        expect(plan.type).to eq Plan::TYPES[:public]
      end
    end

    context "with private repo" do
      it "returns private" do
        public_repo = double("Repo", private?: true)
        plan = Plan.new(public_repo)

        expect(plan.type).to eq Plan::TYPES[:private]
      end
    end
  end

  describe "#price" do
    context "with public repo" do
      it "returns public price" do
        public_repo = double("Repo", private?: false)
        plan = Plan.new(public_repo)

        expect(plan.price).to eq Plan::PRICES[:public]
      end
    end

    context "with private repo" do
      it "returns private price" do
        public_repo = double("Repo", private?: true)
        plan = Plan.new(public_repo)

        expect(plan.price).to eq Plan::PRICES[:private]
      end
    end
  end
end
