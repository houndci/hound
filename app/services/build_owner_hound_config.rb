# frozen_string_literal: true
class BuildOwnerHoundConfig
  HEAD = "HEAD"

  def self.run(*args)
    new(*args).run
  end

  def initialize(owner)
    @owner = owner
  end

  def run
    if owner.has_config_repo?
      github = GithubApi.new(Hound::GITHUB_TOKEN)
      commit = Commit.new(owner.config_repo, HEAD, github)
      HoundConfig.new(commit)
    else
      false
    end
  end

  private

  attr_reader :owner
end
