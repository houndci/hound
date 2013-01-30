class BuildsController < ApplicationController
  skip_before_filter :authenticate
  before_filter :authorize_github

  def create
    api = GithubApi.new(user.github_token)
    api.create_status(
      pull_request.full_repo_name,
      pull_request.sha,
      'success',
      'Hound approves'
    )

    render nothing: true
  end

  private

  def user
    @user ||= User.find_by_github_username(pull_request.github_login)
  end

  def pull_request
    @pull_request ||= PullRequest.new(params[:payload])
  end

  def authorize_github
    if params[:token] != user.github_token
      render nothing: true, status: 401
    end
  end
end
