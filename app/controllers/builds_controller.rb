class BuildsController < ApplicationController
  skip_before_filter :authenticate
  before_filter :authorize_github

  def create
    build_runner.run(pull_request, github_api)
    render nothing: true
  end

  private

  def authorize_github
    if params[:token] != user.github_token
      render nothing: true, status: 401
    end
  end

  def user
    @user ||= User.find_by_github_username(pull_request.github_login)
  end

  def pull_request
    debugger
    @pull_request ||= PullRequest.new(params[:payload])
  end

  def build_runner
    BuildRunner.new
  end

  def github_api
    GithubApi.new(user.github_token)
  end
end
