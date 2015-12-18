class ReposController < ApplicationController
  def index
    respond_to do |format|
      format.html

      format.json do
        if current_user.has_repos_with_missing_information?
          current_user.repos.clear
        end

        repos = current_user.repos_by_activation_ability.includes(:subscription)

        render json: repos
      end
    end
  end
end
