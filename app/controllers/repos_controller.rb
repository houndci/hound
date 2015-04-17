class ReposController < ApplicationController
  before_action :save_token

  def index
    respond_to do |format|
      format.html

      format.json do
        if current_user.has_repos_with_missing_information?
          current_user.repos.clear
        end

        repos = current_user.
          repos.
          order(active: :desc, full_github_name: :asc).
          includes(:subscription)

        render json: repos
      end
    end
  end

  private

  def save_token
    if current_user.token.blank?
      current_user.update!(token: session[:github_token])
    end
  end
end
