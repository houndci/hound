class ReposController < ApplicationController
  def index
    client = Octokit::Client.new(
      login: current_user.github_username,
      oauth_token: session['github_token']
    )
    @repos = client.repos
  end
end
