# frozen_string_literal: true

class SubmitReview
  static_facade :call
  pattr_initialize :build

  def call
    if new_violations.any? || build.review_errors.any?
      send_review(new_violations)
    end
  end

  private

  def send_review(violations)
    # github.create_pull_request_review(
    #   build.repo_name,
    #   build.pull_request_number,
    #   violations.map { |violation| build_comment(violation) },
    #   ReviewBody.new(build.review_errors).to_s,
    # )

    # incorporate review_errors in check run, if any
    # handle Hound config "fail_on_violations"

    check_run_ids = github.send(:client).check_runs_for_ref(
      build.repo_name,
      build.commit_sha,
      status: "queued"
    ).check_runs.map(&:id)

    annotations = violations.map do |violation|
      {
        path: violation.filename,
        start_line: violation.patch_position, # maybe we can support line ranges
        end_line: violation.patch_position,
        annotation_level: "notice",
        message: violation.messages.join(CommentingPolicy::COMMENT_LINE_DELIMITER)
      }
    end

    check_run_ids.each do |check_run_id|
      api.send(:client).update_check_run(
        build.repo_name,
        check_run_id,
        name: "Hound",
        status: "completed",
        conclusion: "success", # success, failure, neutral
        completed_at: Time.now.utc.iso8601,
        output: {
          title: "Hound",
          # summary: "Hound Summary\n-There were a few issues",
          # text: "RuboCop version 0.123",
          annotations: annotations,
        },
        # actions: [
        #   {
        #     label: "Fix this",
        #     description: "Do some magic",
        #     identifier: "fix_rubocop_notices"
        #   }
        # ]
      )
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
