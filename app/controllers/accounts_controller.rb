class AccountsController < ApplicationController
  def show
    @account_page = AccountPage.new(find_subscribed_repos)
  end

  def update
    render json: params[:account], status: :created
  end

  private

  def find_subscribed_repos
    current_user.subscribed_repos.order(:full_github_name)
  end
end
