class OwnerHoundConfigBuilder
  HEAD = "HEAD".freeze
  def self.run(repo, default)
    new(repo, default).run
  end

  def initialize(repo, default)
    @repo = repo
    @default = default
  end

  def run
    if repo.owner.has_config_repo?
      github = GithubApi.new(Hound::GITHUB_TOKEN)
      commit = Commit.new(repo.owner.config_repo, HEAD, github)
      HoundConfig.new(commit)
    else
      default
    end
  end

  private

  attr_reader :repo, :default
end
