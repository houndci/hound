class RepoDeactivationsController < ApplicationController
  def create
    Repo.where(github_id: params[:github_id]).update_all(active: false)
    render nothing: true
  end
end
