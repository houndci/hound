class BuildsController < ApplicationController
  before_filter :authorize_github

  skip_before_filter :authenticate

  def create
    build_runner.run(commit, github_api)
    render nothing: true
  end

  private

  def authorize_github
    if params[:token] != user.github_token
      render nothing: true, status: 401
    end
  end

  def user
    @user ||= User.find_by_github_username(commit.pusher)
  end

  def commit
    puts '*' * 20
    p params
    puts '*' * 20
    @commit ||= Commit.new(params[:payload])
  end

  def build_runner
    BuildRunner.new
  end

  def github_api
    GithubApi.new(user.github_token)
  end
end
