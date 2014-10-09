require "fast_spec_helper"
require "app/models/plan"

describe Plan do
  describe "#type" do
    context "with public repo" do
      it "returns public" do
        public_repo = double("Repo", private?: false, exempt?: false)
        plan = Plan.new(public_repo)

        expect(plan.type).to eq "public"
      end
    end

    context "with private repo" do
      it "returns private" do
        private_repo = double("Repo", private?: true, exempt?: false)
        plan = Plan.new(private_repo)

        expect(plan.type).to eq "private"
      end
    end

    context "with exempt repo" do
      it "returns exempt" do
        exempt_repo = double("Repo", exempt?: true)
        plan = Plan.new(exempt_repo)

        expect(plan.type).to eq "exempt"
      end
    end
  end

  describe "#price" do
    context "with public repo" do
      it "returns public price" do
        public_repo = double("Repo", private?: false, exempt?: false)
        plan = Plan.new(public_repo)

        expect(plan.price).to eq 0
      end
    end

    context "with private repo" do
      it "returns private price" do
        private_repo = double("Repo", private?: true, exempt?: false)
        plan = Plan.new(private_repo)

        expect(plan.price).to eq 12
      end
    end

    context "with exempt repo" do
      it "returns exempt price" do
        exempt_repo = double("Repo", exempt?: true)
        plan = Plan.new(exempt_repo)

        expect(plan.price).to eq 0
      end
    end
  end
end
