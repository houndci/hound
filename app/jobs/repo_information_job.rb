class RepoInformationJob
  extend Retryable

  @queue = :low

  def self.perform(repo_id, github_token)
    repo = Repo.find(repo_id)
    github = GithubApi.new(github_token)
    github_data = github.repo(repo.full_github_name)

    repo.update_attributes!(
      private: github_data[:private],
      in_organization: github_data[:organization].present?
    )
  rescue Resque::TermException
    Resque.enqueue(self, user_id, github_token)
  end
end
