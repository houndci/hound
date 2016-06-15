# frozen_string_literal: true
class BuildOwnerHoundConfig
  LATEST_SHA = "HEAD"

  def self.run(*args)
    new(*args).run
  end

  def initialize(owner)
    @owner = owner
  end

  def run
    if owner.has_config_repo?
      github = GithubApi.new(user_token)
      commit = Commit.new(config_repo.full_github_name, LATEST_SHA, github)
      HoundConfig.new(commit)
    end
  end

  private

  attr_reader :owner

  def user_token
    UserToken.new(config_repo).token
  end

  def config_repo
    Repo.find_or_create_with(full_github_name: owner.config_repo)
  end
end
