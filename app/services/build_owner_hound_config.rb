# frozen_string_literal: true
class BuildOwnerHoundConfig
  LATEST_SHA = "HEAD"

  static_facade :call

  def initialize(owner)
    @owner = owner
  end

  def call
    if owner.has_config_repo? && config_repo_reachable?
      commit = Commit.new(config_repo.name, LATEST_SHA, github)
      HoundConfig.new(commit)
    else
      HoundConfig.new(EmptyCommit.new)
    end
  end

  private

  attr_reader :owner

  def github
    @_github ||= GitHubApi.new(user_token)
  end

  def user_token
    UserToken.new(config_repo).token
  end

  def config_repo_reachable?
    !!github.repo(config_repo.name)
  rescue Octokit::InvalidRepository, Octokit::NotFound, Octokit::Unauthorized
    false
  end

  def config_repo
    Repo.find_or_initialize_by(name: owner.config_repo)
  end
end
