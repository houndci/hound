class RepoActivationsController < ApplicationController
  def create
    activator = RepoActivator.new
    activator.activate(
      params[:github_id].to_i,
      params[:full_github_name],
      current_user,
      github_api,
      "http://#{request.host_with_port}"
    )

    render nothing: true
 end

  def destroy
    activator = RepoActivator.new
    repo = current_user.github_repo(params[:id])

    activator.deactivate(
      github_api,
      repo
    )

    render nothing: true
  end

  private

  def github_api
    GithubApi.new(current_user.github_token)
  end
end
