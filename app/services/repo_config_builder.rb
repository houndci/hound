class RepoConfigBuilder
  def initialize(repo:, token:)
    @repo = repo
    @token = token
  end

  def config_for(linter_name)
    case linter_name
    when "ruby"
      build_ruby_config
    end
  end

  private

  def build_ruby_config
    ruby_config = Config::Ruby.new(hound_config, "ruby")
    config = RubyConfigBuilder.new(ruby_config.content, @repo.owner.name).config
    ConfigFile.new(content: config.to_yaml, format: :yaml)
  end

  def hound_config
    HoundConfig.new(head_commit)
  end

  def head_commit
    Commit.new(@repo.full_github_name, default_branch, github_api)
  end

  def default_branch
    repo = github_api.repo(@repo.full_github_name)
    repo["default_branch"]
  end

  def github_api
    @_github_api ||= GithubApi.new(@token)
  end
end
