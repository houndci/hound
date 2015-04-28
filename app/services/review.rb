class Review
  MAX_COMMENTS = ENV.fetch("MAX_COMMENTS").to_i

  static_facade :run, :build_worker, :file, :violations_attributes

  def run
    mark_build_worker_complete

    if all_workers_completed?
      commenter.comment_on_violations(priority_violations)
      create_success_status
      track_subscribed_build_completed
    end
  end

  private

  def all_workers_completed?
    build.build_workers.all?(&:completed?)
  end

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
      I18n.t(:success_status, count: violation_count)
    )
  end

  def violations
    @violations ||= Violation.transaction do
      violations_attributes.flat_map do |violation|
        line = pull_request_file.line_at(violation["line_number"].to_i)

        if line.changed?
          create_violation(
            filename: file["name"],
            patch_position: line.patch_position,
            line_number: violation["line_number"],
            messages: violation["messages"],
          )
        end
      end
    end
  end

  def create_violation(attributes)
    build.violations.create!(
      filename: attributes[:filename],
      patch_position: attributes[:patch_position],
      line_number: attributes[:line_number],
      messages: attributes[:messages],
    )
  end

  def priority_violations
    violations.take(MAX_COMMENTS)
  end

  def violation_count
    violations.sum(&:messages_count)
  end

  def commenter
    Commenter.new(pull_request)
  end

  def pull_request
    PullRequest.new(review_payload, ENV["HOUND_GITHUB_TOKEN"])
  end

  def build
    build_worker.build
  end

  def pull_request_file
    @pull_request_file ||= PullRequestFile.new(
      file["name"],
      file["content"],
      file["patch_body"],
    )
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
    GithubApi.new(ENV["HOUND_GITHUB_TOKEN"])
  end
end
