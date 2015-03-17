class Reviewer
  MAX_COMMENTS = ENV.fetch("MAX_COMMENTS").to_i

  def self.run(build_worker, file, violations_attrs)
    new(build_worker, file, violations_attrs).run
  end

  def initialize(build_worker, file, violations_attrs)
    @build_worker = build_worker
    @file = file
    @violations_attrs = violations_attrs
  end

  def run
    commenter.comment_on_violations(priority_violations)
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

  def violations
    violations_attrs.flat_map do |violation|
      line = commit_file.line_at(violation[:line_number])

      if line.changed?
        build.violations.create!(
          filename: file[:filename],
          patch_position: line.patch_position,
          line_number: violation[:line_number],
          messages: violation[:messages]
        )
      end
    end
  end

  def priority_violations
    violations.take(MAX_COMMENTS)
  end

  def commenter
    Commenter.new(pull_request)
  end

  def pull_request
    PullRequest.new(review_payload)
  end

  def build
    build_worker.build
  end

  def commit_file
    CommitFile.new(file[:filename], file[:content], file[:patch])
  end

  def repo
    build.repo
  end

  def review_payload
    Payload.new(
      {
        number: build.pull_request_number,
        pull_request: { head: { sha: build.commit_sha } },
        repository: { full_name: repo.full_github_name }
      }.to_json
    )
  end

  def github
    @github ||= GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
  end
end
