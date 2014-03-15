class BuildRunner
  IGNORED_FILES = ['db/schema.rb']

  include Rails.application.routes.url_helpers

  def initialize(payload_data)
    @payload_data = payload_data
  end

  def run
    style_checker = StyleChecker.new(last_commit_files, pull_request.config)
    violations = style_checker.violations
    build = repo.builds.create!(violations: violations)

    if violations.any?
      comment_on_failures(violations)
    end
  end

  def valid?
    repo && payload.valid_action?
  end

  private

  def last_commit_files
    pull_request.head_commit_files.reject do |file|
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
        modified_line = file_violation.modified_lines.detect do |modified_line|
          modified_line.line_number == line_violation.line_number
        end

        pull_request.add_comment(
          file_violation.filename,
          modified_line.diff_position,
          line_violation.messages.join('<br>')
        )
      end
    end
  end
end
