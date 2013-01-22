class ReposController < ApplicationController
  def index
    @all_repos = current_user_repos
    all_repo_ids = @all_repos.map(&:id)
    @active_repo_ids = Repo.where(github_id: all_repo_ids, active: true).map(&:github_id)
  end

  private

  def current_user_repos
    api = GithubApi.new(session['github_token'])
    api.get_repos
  end
end
