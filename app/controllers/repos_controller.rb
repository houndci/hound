class ReposController < ApplicationController
  respond_to :json

  def index
    if current_user.has_repos_with_missing_information?
      current_user.repos.clear
    end

    respond_with current_user.repos.order(active: :desc, full_github_name: :asc)
  end
end
