class ReportInvalidConfig
  static_facade :call

  def initialize(pull_request_number:, commit_sha:, message:)
    @pull_request_number = pull_request_number
    @commit_sha = commit_sha
    @message = message
  end

  def call
    commit_status.set_config_error(message)
  end

  private

  attr_reader :pull_request_number, :commit_sha, :message

  def commit_status
    @commit_status ||= CommitStatus.new(
      repo: build.repo,
      sha: commit_sha,
      github_auth: build.github_auth,
    )
  end

  def build
    @build ||= Build.find_by!(
      pull_request_number: pull_request_number,
      commit_sha: commit_sha,
    )
  end
end
