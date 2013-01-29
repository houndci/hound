require 'open-uri'

class BuildsController < ApplicationController
  skip_before_filter :authenticate

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
    User.where(github_username: pull_request.user_login).first
  end

  def pull_request
    @pull_request ||= PullRequest.new(params[:pull_request])
  end
end
