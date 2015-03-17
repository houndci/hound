class Reviewer
  def self.run(build_worker, file, violations_attrs)
    new(build_worker, file, violations_attrs).run
  end

  def initialize(build_worker, file, violations_attrs)
    @build_worker = build_worker
    @file = file
    @violations_attrs = violations_attrs
  end

  def run
    # Comment
    save_violations
    create_success_status
    track_subscribed_build_completed
    mark_build_worker_complete
  end

  private

  attr_reader :build_worker, :file, :violations_attrs

  def mark_build_worker_complete
    build_worker.update!(completed_at: Time.now)
  end

  def track_subscribed_build_completed
    if repo.subscription
      user = repo.subscription.user
      analytics = Analytics.new(user)
      analytics.track_build_completed(repo)
    end
  end

  def create_success_status
    github.create_success_status(
      repo.full_github_name,
      build.commit_sha,
      I18n.t(:success_status)
    )
  end

  def save_violations
    violations_attrs.each do |violation_attr|
      commit_file = CommitFile.new(file[:filename], file[:content], file[:patch])
      line = commit_file.line_at(violation_attr[:line_number])

      Violation.create!(
        filename: violation_attr[:filename],
        patch_position: line.patch_position,
        line_number: violation_attr[:line_number],
        messages: violation_attr[:messages],
        build_id: violation_attr[:build_id],
      )
    end
  end

  def build
    build_worker.build
  end

  def repo
    build.repo
  end

  def github
    @github ||= GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
  end
end
