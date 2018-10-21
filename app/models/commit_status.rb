class CommitStatus
  def initialize(repo:, sha:, github_auth:)
    @repo = repo
    @sha = sha
    @github_auth = github_auth
  end

  def set_pending
    github.create_pending_status(repo.name, sha, I18n.t(:pending_status))
  rescue Octokit::NotFound
    notify_sentry("Failed to set pending status")
    remove_user_from_repo
    raise
  end

  def set_success(violation_count)
    message = I18n.t(:complete_status, count: violation_count)
    github.create_success_status(repo.name, sha, message)
  rescue Octokit::NotFound
    notify_sentry("Failed to set success status")
    remove_user_from_repo
    raise
  end

  def set_failure(violation_count)
    create_error_status(I18n.t(:complete_status, count: violation_count))
  end

  def set_config_error(message)
    create_error_status(message, configuration_url)
  end

  def set_internal_error
    create_error_status(I18n.t(:hound_error_status))
  end

  def set_past_due_status(invoice_url)
    create_error_status(I18n.t(:past_due_status), invoice_url)
  end

  private

  def remove_user_from_repo
    github_auth.user && repo.remove_membership(github_auth.user)
  end

  def create_error_status(message, url = nil)
    github.create_error_status(repo.name, sha, message, url)
  rescue Octokit::NotFound
    notify_sentry("Failed to set error status", message: message, url: url)
    remove_user_from_repo
    raise
  end

  attr_reader :repo, :sha, :github_auth

  def configuration_url
    ENV.fetch("DOCS_URL")
  end

  def github
    @_github ||= GitHubApi.new(github_auth.token)
  end

  def notify_sentry(message, metadata = {})
    Raven.capture_message(
      message,
      extra: {
        repo_name: repo.name,
        sha: sha,
      }.merge(metadata),
    )
  end
end
