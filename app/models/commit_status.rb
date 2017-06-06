class CommitStatus
  def initialize(repo_name:, sha:, token:)
    @repo_name = repo_name
    @sha = sha
    @token = token
  end

  def set_pending
    github.create_pending_status(repo_name, sha, I18n.t(:pending_status))
  end

  def set_success(violation_count)
    message = I18n.t(:complete_status, count: violation_count)
    github.create_success_status(repo_name, sha, message)
  end

  def set_failure(violation_count)
    message = I18n.t(:complete_status, count: violation_count)
    github.create_error_status(repo_name, sha, message)
  end

  def set_config_error(message, details_url = nil)
    github.create_error_status(repo_name, sha, message, details_url)
  end

  def set_internal_error
    message = I18n.t(:hound_error_status)
    github.create_error_status(repo_name, sha, message)
  end

  private

  attr_reader :repo_name, :sha, :token

  def github
    @github ||= GithubApi.new(token)
  end
end
