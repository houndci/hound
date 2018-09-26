require "rails_helper"

RSpec.describe UpdateGitHubPlans do
  describe ".call" do
    it "updates marketplace plan ids for all owners" do
      owner1 = create(:owner, marketplace_plan_id: 1)
      owner2 = create(:owner, marketplace_plan_id: 2)
      owner3 = create(:owner, marketplace_plan_id: 3)
      stub_marketplace_plans_for_account(
        owner1.github_id => 2,
        owner2.github_id => 1,
        owner3.github_id => 3,
      )

      described_class.call

      expect(owner1.reload.marketplace_plan_id).to eq(2)
      expect(owner2.reload.marketplace_plan_id).to eq(1)
      expect(owner3.reload.marketplace_plan_id).to eq(3)
    end
  end

  def stub_marketplace_plans_for_account(ids_to_plans)
    url = %r{/marketplace_listing/plans/\d+/accounts}
    body = ids_to_plans.map do |id, plan_id|
      {
        id: id,
        marketplace_purchase: {
          plan: {
            id: plan_id,
          },
        },
      }
    end

    stub_request(:get, url).to_return(
      headers: { "Content-Type": "application/json" },
      body: body.to_json,
    )
  end
end
