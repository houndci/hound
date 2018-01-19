class CommitStatus
  def initialize(repo_name:, sha:, token:)
    @repo_name = repo_name
    @sha = sha
    @token = token
  end

  def set_pending
    github.create_pending_status(repo_name, sha, I18n.t(:pending_status))
  rescue Octokit::NotFound
    # noop
  end

  def set_success(violation_count)
    message = I18n.t(:complete_status, count: violation_count)
    github.create_success_status(repo_name, sha, message)
  rescue Octokit::NotFound
    # noop
  end

  def set_failure(violation_count)
    message = I18n.t(:complete_status, count: violation_count)
    create_error_status(repo_name, sha, message)
  end

  def set_config_error(message)
    create_error_status(repo_name, sha, message, configuration_url)
  end

  def set_internal_error
    message = I18n.t(:hound_error_status)
    create_error_status(repo_name, sha, message)
  end

  private

  def create_error_status(repo_name, sha, message, configuration_url = nil)
    github.create_error_status(repo_name, sha, message, configuration_url)
  rescue Octokit::NotFound
    # noop
  end

  attr_reader :repo_name, :sha, :token

  def configuration_url
    Rails.application.routes.url_helpers.configuration_url(host: Hound::HOST)
  end

  def github
    @github ||= GithubApi.new(token)
  end
end
