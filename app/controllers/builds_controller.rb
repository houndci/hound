class BuildsController < ApplicationController
  skip_before_filter :authenticate
  before_filter :authorize_github

  def create
    checker.check(pull_request, user.github_token)
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
    @pull_request ||= PullRequest.new(params[:payload])
  end

  def checker
    StyleChecker.new
  end
end
