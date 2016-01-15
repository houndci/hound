class LinterConfigsController < ApplicationController
  def show
    case params[:linter]
    when "ruby"
      ruby_config = Config::Ruby.new(hound_config, "ruby")
      config = RubyConfigBuilder.new(ruby_config.content, params[:owner]).config
      render body: config.to_yaml, content_type: "text/yaml"
    else
      head 404
    end
  end

  protected

  def repo
    Repo.find_by(full_github_name: full_github_name)
  end

  def full_github_name
    "#{params[:owner]}/#{params[:repo]}"
  end

  def hound_config
    HoundConfig.new(head_commit)
  end

  def head_commit
    Commit.new(full_github_name, default_branch, github_api)
  end

  def default_branch
    repo = github_api.repo(full_github_name)
    repo["default_branch"]
  end

  def github_api
    GithubApi.new(current_user.token)
  end
end
