class RepoInformationJob
  extend Retryable

  @queue = :low

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.touch

    github = GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
    github_data = github.repo(repo.full_github_name)

    repo.update_attributes!(
      private: github_data[:private],
      in_organization: github_data[:organization].present?
    )
  rescue Resque::TermException
    Resque.enqueue(self, repo_id)
  rescue => exception
    Raven.capture_exception(exception, repo: { id: repo_id })
  end
end
