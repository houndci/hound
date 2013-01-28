class BuildsController < ApplicationController
  GITHUB_IPS = [
    '207.97.227.253',
    '50.57.128.197',
    '108.171.174.178',
    '50.57.231.61'
  ]

  skip_before_filter :authenticate
  before_filter :authorize_github

  def create
    api = GithubApi.new(user.github_token)
    api.create_status(
      pull_request.repo_name,
      pull_request.sha,
      'success',
      'Hound approves'
    )

    render nothing: true
  end

  private

  def user
    User.find_by_github_username(pull_request.user_login)
  end

  def pull_request
    @pull_request ||= PullRequest.new(params[:pull_request])
  end

  def authorize_github
    unless GITHUB_IPS.include? request.referer
      render nothing: true, status: 401
    end
  end
end
