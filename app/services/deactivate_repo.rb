class DeactivateRepo
  static_facade :call

  def initialize(github_token:, repo:)
    @github_token = github_token
    @repo = repo
  end

  def call
    if skip_github?
      repo.deactivate
    else
      deactivate_with_github
    end
  end

  private

  attr_reader :github_token, :repo

  def change_repository_state_quietly
    yield
  rescue Octokit::Error => e
    Raven.capture_exception(e)
    false
  end

  def skip_github?
    repo.installation_id || (repo.subscription.present? && missing_membership?)
  end

  def missing_membership?
    Membership.where(repo: repo, user: repo.subscription.user).empty?
  end

  def deactivate_with_github
    change_repository_state_quietly do
      if repo.private?
        remove_hound_from_repo
      end

      delete_webhook && repo.deactivate
    end
  end

  def remove_hound_from_repo
    github.remove_collaborator(repo.name, Hound::GITHUB_USERNAME)
  end

  def github
    @github ||= GitHubApi.new(github_token)
  end

  def delete_webhook
    github.remove_hook(repo.name, repo.hook_id) do
      repo.update(hook_id: nil)
    end
  end
end
