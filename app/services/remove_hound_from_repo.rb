class RemoveHoundFromRepo
  pattr_initialize :repo_name, :github

  def self.run(repo_name, github)
    new(repo_name, github).run
  end

  def run
    if repo.organization
      remove_hound_from_organization
    else
      remove_hound_from_repo
    end
  end

  private

  def repo
    @repo ||= github.repo(repo_name)
  end

  def remove_hound_from_repo
    github.remove_collaborator(repo_name, github_username)
  end

  def remove_hound_from_organization
    true
  end

  def github_username
    @github_username ||= ENV.fetch("HOUND_GITHUB_USERNAME")
  end
end
