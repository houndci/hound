class AccountsController < ApplicationController
  def show
    @subscribed_repos = current_user.subscribed_repos.order(:full_github_name)
    @repo_groups = @subscribed_repos.partition(&:subscription_price)
  end
end
