class BuildRunner
  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end

  def run
    repo.builds.create!(violations: violations)

    commenter = Commenter.new
    commenter.comment_on_violations(violations, pull_request)
  end

  def valid?
    repo && payload.valid_action?
  end

  private

  def violations
    @violations ||= style_checker.violations
  end

  def style_checker
    StyleChecker.new(modified_files, pull_request.config)
  end

  def modified_files
    collection = FileCollection.new(pull_request.pull_request_files)
    collection.relevant_files
  end

  def pull_request
    @pull_request ||= PullRequest.new(payload, ENV['HOUND_GITHUB_TOKEN'])
  end

  def repo
    @repo ||= Repo.active.where(github_id: payload.github_repo_id).first
  end
end
