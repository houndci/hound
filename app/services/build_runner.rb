class BuildRunner
  IGNORED_FILES = ['db/schema.rb']

  include Rails.application.routes.url_helpers

  def initialize(payload_data)
    @payload_data = payload_data
  end

  def run
    pull_request.set_pending_status

    style_checker = StyleChecker.new(pull_request_files)
    build = repo.builds.create!(violations: style_checker.violations)

    if build.violations.any?
      pull_request.set_failure_status(build_url(build.uuid, host: ENV['HOST']))
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
end
