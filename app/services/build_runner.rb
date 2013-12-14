class BuildRunner
  def initialize(pull_request, builds_url = nil)
    @pull_request = pull_request
    @builds_url = builds_url
  end

  def valid?
    @pull_request.valid? && valid_build_action? && repo
  end

  def run
    api.create_pending_status(*api_params, 'Hound is working...')

    style_guide = StyleGuide.new(style_guide_files)
    build = repo.builds.create!(violations: style_guide.violations)

    update_api_status(build, fail: style_guide.violations.any?)
  end

  private

  def update_api_status(build, options = {})
    if options.fetch(:fail)
      api.create_failure_status(
        *api_params, 'Hound does not approve', build_url(build)
      )
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

  def style_guide_files
    pull_request_files.map do |file|
      contents = api.pull_request_file_contents(
        @pull_request.full_repo_name,
        file.filename,
        @pull_request.head_sha
      )
      style_guide_file(file, contents.content)
    end
  end

  def style_guide_file(file, contents)
    decoded_contents = Base64.decode64(contents)
    modified_line_numbers = DiffPatch.new(file.patch).modified_line_numbers
    StyleGuideFile.new(file.filename, decoded_contents, modified_line_numbers)
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

  def pull_request_files
    api.pull_request_files(@pull_request.full_repo_name, @pull_request.number)
  end
end
