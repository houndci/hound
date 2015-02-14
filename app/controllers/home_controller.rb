class HomeController < ApplicationController
  skip_before_action :authenticate, only: [:index]

  before_action :redirect_to_repos, if: :signed_in?

  def index
  end

  private

  def redirect_to_repos
    redirect_to repos_path
  end
end
