class LinterConfigsController < ApplicationController
  def show
    config_builder = RepoConfigBuilder.new(
      repo: repo,
      token: current_user.token,
    )
    config_file = config_builder.config_for(params[:linter])

    if config_file.present?
      render body: config_file.content, content_type: config_file.format
    else
      head 404
    end
  end

  private

  def repo
    Repo.find_by(full_github_name: "#{params[:owner]}/#{params[:repo]}")
  end
end
