class RepoActivationsController < ApplicationController
  def create
    relation = Repo.where(github_id: params[:github_id])

    if relation.count > 0
      relation.update_all(active: true)
    else
      Repo.create(github_id: params[:github_id], active: true)
    end

    render nothing: true
  end
end
