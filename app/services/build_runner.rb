class BuildRunner
  IGNORED_FILES = ['db/schema.rb']

  include Rails.application.routes.url_helpers

  def initialize(payload_data)
    @payload_data = payload_data
  end

  def run
    pull_request.set_pending_status

    style_checker = StyleChecker.new(pull_request_files)
    violations = style_checker.violations
    build = repo.builds.create!(violations: violations)

    if violations.any?
      build_url = build_url(build.uuid, host: ENV['HOST'])
      pull_request.set_failure_status(build_url)
      comment_on_failures(violations)
    else
      pull_request.set_success_status
    end
  end

  def valid?
    repo && payload.valid_action?
  end

  private

  def pull_request_files
    pull_request.files.reject do |file|
      file.removed? || !file.ruby? || IGNORED_FILES.include?(file.filename)
    end
  end

  def pull_request
    @pull_request ||= PullRequest.new(payload, repo.github_token)
  end

  def payload
    @payload ||= Payload.new(@payload_data)
  end

  def repo
    @repo ||= Repo.active.where(github_id: payload.github_repo_id).first
  end

  def comment_on_failures(violations)
    violations.each do |file_violation|
      file_violation.line_violations.each do |line_violation|
        pull_request.add_comment(
          file_violation.filename,
          line_violation.line_number
        )
      end
    end
  end
end
