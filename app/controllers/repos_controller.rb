class ReposController < ApplicationController
  before_action :set_vary_header

  def index
    respond_to do |format|
      format.html

      format.json do
        if current_user.has_repos_with_missing_information?
          current_user.repos.clear
        end

        render(
          json: current_user.repos.order(active: :desc, full_github_name: :asc)
        )
      end
    end
  end

  private

  def set_vary_header
    response.headers["Vary"] = "Accept"
  end
end
