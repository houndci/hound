class ReposController < ApplicationController
  def index
    respond_to do |format|
      format.html

      format.json do
        if current_user.has_repos_with_missing_information?
          current_user.repos.clear
        end

        repos = ReposWithMembershipOrSubscriptionQuery.call(current_user)

        render(
          json: repos,
          bulk_customers_by_org: find_bulk_customers(repos).index_by(&:org)
        )
      end
    end
  end

  private

  def find_bulk_customers(repos)
    BulkCustomer.where(org: repos.map(&:organization).uniq)
  end
end
