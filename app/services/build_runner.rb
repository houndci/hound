class BuildRunner
  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end

  def run
    if repo && relevant_pull_request
      repo.builds.create!(violations: violations)
      commenter.comment_on_violations(violations, pull_request)
    end
  end

  private

  def relevant_pull_request
    pull_request.opened? || pull_request.synchronize?
  end

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

  def commenter
    Commenter.new
  end

  def pull_request
    @pull_request ||= PullRequest.new(payload, ENV['HOUND_GITHUB_TOKEN'])
  end

  def repo
    @repo ||= Repo.active.where(github_id: payload.github_repo_id).first
  end
end
