class ReposController < ApplicationController
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
end
