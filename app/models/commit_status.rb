class CommitStatus
  def initialize(repo_name:, sha:, token:)
    @repo_name = repo_name
    @sha = sha
    @token = token
  end

  def set_pending
    github.create_pending_status(repo_name, sha, I18n.t(:pending_status))
  rescue Octokit::NotFound
    notify_sentry(
      "Failed to set pending status",
      repo_name: repo_name,
      sha: sha
    )
  end

  def set_success(violation_count)
    message = I18n.t(:complete_status, count: violation_count)
    github.create_success_status(repo_name, sha, message)
  rescue Octokit::NotFound
    notify_sentry(
      "Failed to set success status",
      repo_name: repo_name,
      sha: sha
    )
  end

  def set_failure(violation_count)
    create_error_status(
      repo_name: repo_name,
      sha: sha,
      message: I18n.t(:complete_status, count: violation_count),
    )
  end

  def set_config_error(message)
    create_error_status(
      repo_name: repo_name,
      sha: sha,
      message: message,
      url: configuration_url,
    )
  end

  def set_internal_error
    create_error_status(
      repo_name: repo_name,
      sha: sha,
      message: I18n.t(:hound_error_status),
    )
  end

  def set_past_due_status(invoice_url)
    create_error_status(
      repo_name: repo_name,
      sha: sha,
      message: I18n.t(:past_due_status),
      url: invoice_url,
    )
  end

  private

  def create_error_status(repo_name:, sha:, message:, url: nil)
    github.create_error_status(repo_name, sha, message, url)
  rescue Octokit::NotFound
    notify_sentry(
      "Failed to set error status",
      repo_name: repo_name,
      sha: sha,
      message: message,
      url: url
    )
  end

  attr_reader :repo_name, :sha, :token

  def configuration_url
    ENV.fetch("DOCS_URL")
  end

  def github
    @github ||= GitHubApi.new(token)
  end

  def notify_sentry(message, metadata)
    Raven.capture_message(message, extra: metadata)
  end
end
