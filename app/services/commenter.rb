# Print violation messages as comments on given GitHub pull request.
class Commenter
  pattr_initialize :pull_request

  def comment_on_violations(violations)
    violations.each do |violation|
      if policy.comment_on?(violation)
        pull_request.comment_on_violation(violation)
      end
    end
  end

  def remove_resolved_violations(violations)
    pull_request.comments.each do |comment|
      unless policy.comment_matches_any_violation?(comment, violations)
        pull_request.delete_comment(comment.id)
      end
    end
  end

  private

  def policy
    @_policy ||= CommentingPolicy.new(pull_request)
  end
end
