class ReportInvalidConfig
  def self.run(**args)
    new(**args).run
  end

  def initialize(pull_request_number:, commit_sha:, linter_name:)
    @pull_request_number = pull_request_number
    @commit_sha = commit_sha
    @linter_name = linter_name
  end

  def run
    commit_status.set_config_error(linter_name)
  end

  private

  attr_reader :pull_request_number, :commit_sha, :linter_name

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
