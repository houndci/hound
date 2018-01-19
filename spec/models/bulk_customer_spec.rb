require "rails_helper"

describe BulkCustomer do
  describe ".upaid_repos" do
    it "returns non-bulk repos that are active but without subscription" do
      org_name = "bulk_test"
      bulk_repo = create(:repo, :in_private_org, name: "#{org_name}/one")
      unpaid_repo = create(:repo, :in_private_org)
      create(:subscription, :inactive, repo: bulk_repo)
      create(:bulk_customer, org: org_name)
      create(:bulk_customer, org: "some_other_name")

      results = BulkCustomer.unpaid_repos

      expect(results).to eq [unpaid_repo]
    end
  end

  describe "#update_current_repos" do
    it "updates the count of active private repos for the bulk customer" do
      org_name = "bulk_test"
      create(:repo, :in_private_org, name: "#{org_name}/one")
      create(:repo, :in_private_org, :inactive, name: "#{org_name}/two")
      create(:repo, :inactive, name: "#{org_name}/three")
      create(:repo, :in_private_org, name: "other_org/three")
      bulk_customer = build(:bulk_customer, org: org_name)

      bulk_customer.update_current_repos

      expect(bulk_customer.current_repos).to eq 1
    end
  end
end
