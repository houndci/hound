require "spec_helper"
require "app/models/plan"

describe Plan do
  describe "#type" do
    context "with public repo" do
      it "returns public" do
        public_repo = double("Repo", private?: false, bulk?: false)
        plan = Plan.new(public_repo)

        expect(plan.type).to eq "public"
      end
    end

    context "with private repo" do
      it "returns private" do
        private_repo = double("Repo", private?: true, bulk?: false)
        plan = Plan.new(private_repo)

        expect(plan.type).to eq "private"
      end
    end

    context "with bulk repo" do
      it "returns bulk" do
        bulk_repo = double("Repo", bulk?: true)
        plan = Plan.new(bulk_repo)

        expect(plan.type).to eq "bulk"
      end
    end
  end

  describe "#price" do
    context "with public repo" do
      it "returns public price" do
        public_repo = double("Repo", private?: false, bulk?: false)
        plan = Plan.new(public_repo)

        expect(plan.price).to eq 0
      end
    end

    context "with private repo" do
      it "returns private price" do
        private_repo = double("Repo", private?: true, bulk?: false)
        plan = Plan.new(private_repo)

        expect(plan.price).to eq 12
      end
    end

    context "with bulk repo" do
      it "returns bulk price" do
        bulk_repo = double("Repo", bulk?: true)
        plan = Plan.new(bulk_repo)

        expect(plan.price).to eq 0
      end
    end
  end
end
