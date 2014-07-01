require "spec_helper"

describe AccountsHelper do
  describe "#repos_total" do
    it "returns a sum of repo subscription prices" do
      repo1 = double("Repo", subscription_price: 9.00)
      repo2 = double("Repo", subscription_price: 24.00)
      repo3 = double("Repo", subscription_price: 3.25)

      total = repos_total([repo1, repo2, repo3])

      expect(total).to eq "$36.25"
    end
  end
end
