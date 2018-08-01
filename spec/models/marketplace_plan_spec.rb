require "lib/github_api"
require "app/models/app_token"
require "app/models/marketplace_plan"

RSpec.describe MarketplacePlan do
  describe "#current_plan" do
    context "when account subscribes to a plan" do
      it "returns the subscribed plan" do
        owner = instance_double("Owner", github_id: 12345)
        marketplace_plan = described_class.new(owner)
        current_github_plan = double(id: MarketplacePlan::PLANS[1][:id])
        stub_github_api(current_github_plan)

        expect(marketplace_plan.current_plan).to eq(MarketplacePlan::PLANS[1])
      end
    end

    context "when account does not subscribe to a plan" do
      it "returns the first plan" do
        owner = instance_double("Owner", github_id: 12345)
        marketplace_plan = described_class.new(owner)
        stub_github_api(nil)

        expect(marketplace_plan.current_plan).to eq(MarketplacePlan::PLANS[0])
      end
    end
  end

  describe "#next_plan" do
    [
      { current_plan: 0, expected: MarketplacePlan::PLANS[1] },
      { current_plan: 1, expected: MarketplacePlan::PLANS[2] },
      { current_plan: 2, expected: nil },
    ].each do |test_data|
      context "when current plan index is #{test_data[:current_plan]}" do
        it "returns plan for #{test_data[:expected]&.repos} repos" do
          owner = instance_double("Owner", github_id: 12345)
          marketplace_plan = described_class.new(owner)
          current_plan = MarketplacePlan::PLANS[test_data[:current_plan]]
          current_github_plan = double(id: current_plan.id)
          stub_github_api(current_github_plan)

          expect(marketplace_plan.next_plan).to eq(test_data[:expected])
        end
      end
    end
  end

  describe "#previous_plan" do
    [
      { current_plan: 0, expected: false },
      { current_plan: 1, expected: MarketplacePlan::PLANS[0] },
      { current_plan: 2, expected: MarketplacePlan::PLANS[1] },
    ].each do |test_data|
      context "when current plan index is #{test_data[:current_plan]}" do
        it "returns #{test_data[:expected] || 'no'} plan" do
          owner = instance_double("Owner", github_id: 12345)
          marketplace_plan = described_class.new(owner)
          current_plan = MarketplacePlan::PLANS[test_data[:current_plan]]
          current_github_plan = double(id: current_plan.id)
          stub_github_api(current_github_plan)

          expect(marketplace_plan.previous_plan).to eq(test_data[:expected])
        end
      end
    end
  end

  describe "#upgrade?" do
    [
      { current_plan: 0, repos: 0, expected: true },
      { current_plan: 1, repos: 3, expected: false },
      { current_plan: 1, repos: 4, expected: true },
      { current_plan: 2, repos: 5, expected: false },
      { current_plan: 2, repos: 19, expected: false },
      { current_plan: 2, repos: 20, expected: true },
    ].each do |test_data|
      context "when account has #{test_data[:repos]} private repos" do
        it "returns #{test_data[:expected]}" do
          owner = instance_double(
            "Owner",
            github_id: 12345,
            active_private_repos_count: test_data[:repos],
          )
          marketplace_plan = described_class.new(owner)
          current_plan = MarketplacePlan::PLANS[test_data[:current_plan]]
          current_github_plan = double(id: current_plan.id)
          stub_github_api(current_github_plan)

          expect(marketplace_plan.upgrade?).to eq(test_data[:expected])
        end
      end
    end
  end

  describe "#upgrade_url" do
    it "returns the url to the next plan on the marketplace" do
      owner = instance_double("Owner", github_id: 12345, name: "foo")
      marketplace_plan = described_class.new(owner)
      current_plan = MarketplacePlan::PLANS[1]
      next_plan = MarketplacePlan::PLANS[2]
      current_github_plan = double(id: current_plan.id)
      stub_github_api(current_github_plan)

      expect(marketplace_plan.upgrade_url).to eq(
        "#{MarketplacePlan::MARKETPLACE_UPGRADE_URL}/order/" +
          "#{next_plan.slug}?account=#{owner.name}",
      )
    end
  end

  describe "#downgrade_url" do
    it "returns the url to the previoius plan on the marketplace" do
      owner = instance_double("Owner", github_id: 12345, name: "foo")
      marketplace_plan = described_class.new(owner)
      current_plan = MarketplacePlan::PLANS[1]
      previous_plan = MarketplacePlan::PLANS[0]
      github_plan = double(id: current_plan.id)
      stub_github_api(github_plan)

      expect(marketplace_plan.downgrade_url).to eq(
        "#{MarketplacePlan::MARKETPLACE_UPGRADE_URL}/order/" +
          "#{previous_plan.slug}?account=#{owner.name}",
      )
    end
  end

  def stub_github_api(plan)
    app_token = instance_double("AppToken", generate: "abcdefg")
    api = instance_double("GitHubApi", plan_for_account: plan)
    allow(AppToken).to receive(:new).and_return(app_token)
    allow(GitHubApi).to receive(:new).and_return(api)
  end
end
