class BuildRunner
  include Rails.application.routes.url_helpers

  def initialize(pull_request)
    @pull_request = pull_request
  end

  def run
    @pull_request.set_pending_status

    style_checker = StyleChecker.new(@pull_request.files)
    build = repo.builds.create!(violations: style_checker.violations)

    if style_checker.violations.any?
      @pull_request.set_failure_status(build_url(build, host: ENV['HOST']))
    else
      @pull_request.set_success_status
    end
  end

  private

  def repo
    @pull_request.repo
  end
end
