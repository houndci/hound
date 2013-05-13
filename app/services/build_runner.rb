class BuildRunner
  def initialize(pull_request)
    @pull_request = pull_request
  end

  def run
    api_params = [@pull_request.full_repo_name, @pull_request.head_sha]
    api.create_pending_status(*api_params, 'Hound is working...')

    style_guide = StyleGuide.new
    style_guide.check(pull_request_additions)

    if style_guide.violations.any?
      api.create_failure_status(*api_params, 'Hound does not approve')
    else
      api.create_successful_status(*api_params, 'Hound approves')
    end
  end

  def pull_request_additions
    diff = GitDiff.new(patch)
    diff.additions
  end

  private

  def api
    if @api.nil?
      user = User.where(github_username: @pull_request.repo_owner).first
      @api = GithubApi.new(user.github_token)
    end

    @api
  end

  def patch
    files = api.pull_request_files(
      @pull_request.full_repo_name,
      @pull_request.number
    )

    files.map(&:patch).join('\n')
  end
end
