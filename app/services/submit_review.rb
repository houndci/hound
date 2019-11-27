# frozen_string_literal: true

class SubmitReview
  static_facade :call
  pattr_initialize :build

  def call
    if new_violations.any? || build.review_errors.any?
      comments = new_violations.map { |violation| build_comment(violation) }

      if build.repo.installation_id
        remove_resolved_violations
      end

      send_review(comments)
    end
  end

  private

  def send_review(comments)
    github.create_pull_request_review(
      build.repo_name,
      build.pull_request_number,
      comments,
      ReviewBody.new(build.review_errors).to_s,
    )
  end

  def remove_resolved_violations
    commenting_policy.outdated_comments(build.violations).each do |comment|
      github.delete_pull_request_comment(build.repo_name, comment)
    end
  end

  def new_violations
    @_new_violations ||= build.violations.
      select { |violation| commenting_policy.comment_on?(violation) }.
      take(Hound::MAX_COMMENTS)
  end

  def build_comment(violation)
    {
      path: violation.filename,
      position: violation.patch_position,
      body: violation.messages.join(CommentingPolicy::COMMENT_LINE_DELIMITER),
    }
  end

  def commenting_policy
    @_commenting_policy ||= CommentingPolicy.new(existing_comments)
  end

  def existing_comments
    github.pull_request_comments(build.repo_name, build.pull_request_number)
  end

  def github
    @_github ||= GitHubApi.new(github_token)
  end

  def github_token
    if build.repo.installation_id
      app = GitHubApi.new(AppToken.new.generate)
      app.create_installation_token(build.repo.installation_id)
    else
      Hound::GITHUB_TOKEN
    end
  end
end
