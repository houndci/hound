# Print violation messages as comments on given GitHub pull request.
class Commenter
  def comment_on_violations(violations, pull_request)
    violations.each do |violation|
      previous_comments = previous_line_comments(pull_request, violation)

      if commenting_policy.comment_permitted?(
        pull_request,
        previous_comments,
        violation
      )
        pull_request.add_comment(violation)
      end
    end
  end

  private

  def commenting_policy
    CommentingPolicy.new
  end

  def previous_line_comments(pull_request, violation)
    existing_comments(pull_request).select do |comment|
      comment.original_position == violation.line.patch_position &&
        comment.path == violation.filename
    end
  end

  def existing_comments(pull_request)
    @existing_comments ||= pull_request.comments
  end
end
