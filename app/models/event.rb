class Event
  pattr_initialize :payload, :github_token

  def relevant?
    config.enabled_for?(name)
  end

  def files
    commits.flat_map do |commit|
      commit.files
    end
  end

  def config
    @config ||= RepoConfig.new(head_commit)
  end

  private

  def api
    @api ||= GithubApi.new(@github_token)
  end

  def full_repo_name
    payload.full_repo_name
  end

  def self.new_from_payload(payload, github_token)
    (payload.pull_request? ? PullRequest : Push).new(payload, github_token)
  end

  def name
    self.class.name.pluralize.underscore
  end
end
