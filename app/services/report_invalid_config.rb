class ReportInvalidConfig
  static_facade :call

  def initialize(pull_request_number:, commit_sha:, linter_name:, message: "", details_url: nil)
    @pull_request_number = pull_request_number
    @commit_sha = commit_sha
    @linter_name = linter_name
    @message = message
    @details_url = details_url
  end

  def call
    commit_status.set_config_error(message, details_url)
  end

  private

  attr_reader :pull_request_number, :commit_sha, :linter_name, :details_url

  def message
    @message.presence || I18n.t(:config_error_status, linter_name: linter_name)
  end

  def commit_status
    @commit_status ||= CommitStatus.new(
      repo_name: build.repo_name,
      sha: commit_sha,
      token: build.user_token,
    )
  end

  def build
    @build ||= Build.find_by!(
      pull_request_number: pull_request_number,
      commit_sha: commit_sha,
    )
  end
end
