class BuildRunner
  def initialize(pull_request)
    @pull_request = pull_request
    @style_guide = StyleGuide.new
  end

  def valid?
    @pull_request.valid? && valid_build_action? && repo
  end

  def run
    api.create_pending_status(*api_params, 'Hound is working...')
    @style_guide.check(pull_request_additions)
    update_api_status

    repo.builds.create!(violations: @style_guide.violations)
  end

  private

  def update_api_status
    if @style_guide.violations.any?
      api.create_failure_status(*api_params, 'Hound does not approve')
    else
      api.create_successful_status(*api_params, 'Hound approves')
    end
  end

  def api_params
    [@pull_request.full_repo_name, @pull_request.head_sha]
  end

  def pull_request_additions
    diff = GitDiff.new(patch)
    diff.additions
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

  def patch
    files = api.pull_request_files(
      @pull_request.full_repo_name,
      @pull_request.number
    )

    files.map(&:patch).join('\n')
  end
end
