class ReposController < ApplicationController
  respond_to :json

  def index
    respond_with current_user.repos.order(active: :desc, full_github_name: :asc)
  end
end
