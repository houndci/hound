class RebuildsController < ApplicationController
  def create
    RebuildPullRequest.call(
      repo: repo,
      pull_request_number: pull_request_number,
    )
    flash[:notice] = t(".success")

    redirect_to builds_path
  end

  private

  def repo
    current_user.repos.find(params[:repo_id])
  end

  def pull_request_number
    params.require(:rebuild)[:pull_request_number]
  end
end
