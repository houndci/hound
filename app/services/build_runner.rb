class BuildRunner
  def initialize(pull_request, builds_url = nil)
    @pull_request = pull_request
    @style_guide = StyleGuide.new
    @builds_url = builds_url
  end

  def valid?
    @pull_request.valid? && valid_build_action? && repo
  end

  def run
    api.create_pending_status(*api_params, 'Hound is working...')
    @style_guide.check(api.pull_request_files(@pull_request))
    build = repo.builds.create!(violations: @style_guide.violations)
    update_api_status(build)
  end

  private

  def update_api_status(build = nil)
    if @style_guide.violations.any?
      api.create_failure_status(*api_params, 'Hound does not approve', build_url(build))
    else
      api.create_successful_status(*api_params, 'Hound approves')
    end
  end

  def build_url(build)
    "#{@builds_url}/#{build.id}"
  end

  def api_params
    [@pull_request.full_repo_name, @pull_request.head_sha]
  end

  def valid_build_action?
    valid_actions = %w(opened synchronize)
    valid_actions.include?(@pull_request.action)
  end

  def repo
    @repo ||= Repo.active.where(github_id: @pull_request.github_repo_id).first
  end

  def api
    @api ||= GithubApi.new(repo.github_token)
  end
end
