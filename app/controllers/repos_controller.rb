class ReposController < ApplicationController
  before_action :fetch_email_address, only: [:index]

  respond_to :json

  def index
    if current_user.has_repos_with_missing_information?
      current_user.repos.clear
    end

    respond_with current_user.repos.order(active: :desc, full_github_name: :asc)
  end

  private

  def fetch_email_address
    if current_user.email_address.blank?
      JobQueue.push(EmailAddressJob, current_user.id, session[:github_token])
    end
  end
end
