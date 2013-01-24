class RepoActivationsController < ApplicationController
  def create
    repo = Repo.find_by_github_id(params[:github_id])
    repo.activate

    render nothing: true
  end
end
