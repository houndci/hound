class Commenter
  def comment_on_violations(file_violations, pull_request)
    existing_comments = pull_request.comments

    file_violations.each do |file_violation|
      file_violation.line_violations.each do |line_violation|
        line = line_violation.line
        previous_comments = previous_line_comments(
          existing_comments,
          line.patch_position,
          file_violation.filename
        )

        if commenting_policy.comment_permitted?(
          pull_request,
          previous_comments,
          line_violation
        )
          pull_request.add_comment(
            file_violation.filename,
            line.patch_position,
            line_violation.messages.join('<br>')
          )
        end
      end
    end
  end

  private

  def commenting_policy
    CommentingPolicy.new
  end

  def previous_line_comments(existing_comments, line_patch_position, filename)
    existing_comments.select do |comment|
      comment.position == line_patch_position && comment.path == filename
    end
  end
end
