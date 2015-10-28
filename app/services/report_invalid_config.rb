class ReportInvalidConfig
  def self.run(**args)
    new(**args).run
  end

  def initialize(pull_request_number:, commit_sha:, filename:)
    @pull_request_number = pull_request_number
    @commit_sha = commit_sha
    @filename = filename
  end

  def run
    commit_status.set_config_error(filename)
  end

  private

  attr_reader :pull_request_number, :commit_sha, :filename

  def commit_status
    @commit_status ||= CommitStatus.new(
      repo_name: build.repo_name,
      sha: commit_sha,
      token: Hound::GITHUB_TOKEN,
    )
  end

  def build
    @build ||= Build.find_by!(
      pull_request_number: pull_request_number,
      commit_sha: commit_sha,
    )
  end
end
