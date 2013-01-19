class ReposController < ApplicationController
  def index
    @repos = current_user_repos
  end

  private

  def current_user_repos
    api = GithubApi.new(session['github_token'])
    api.get_repos
  end
end
