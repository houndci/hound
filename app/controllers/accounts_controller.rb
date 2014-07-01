class AccountsController < ApplicationController
  def show
    @repos = current_user.subscribed_repos.order(:full_github_name)
    @org_repos, @personal_repos = @repos.partition(&:in_organization?)
  end
end
