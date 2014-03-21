class ReposController < ApplicationController
  respond_to :json

  def index
    respond_with current_user.repos.order(:full_github_name)
  end
end
