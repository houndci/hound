class RepoActivationsController < ApplicationController
  def create
    repo = Repo.where(github_id: params[:github_id]).first

    if repo
      repo.update_attributes!(active: true)
    else
      Repo.create!(github_id: params[:github_id], active: true)
    end

    render nothing: true
  end
end
