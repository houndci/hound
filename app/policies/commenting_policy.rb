class CommentingPolicy
  pattr_initialize :pull_request

  def comment_on?(violation)
    unreported_violation_messages(violation).any?
  end

  private

  def unreported_violation_messages(violation)
    violation.messages - existing_violation_messages(violation)
  end

  def existing_violation_messages(violation)
    previous_comments_on_line(violation).
      map(&:body).
      flat_map { |body| body.split(PullRequest::COMMENT_LINE_DELIMITER) }
  end

  def previous_comments_on_line(violation)
    pull_request.comments.select do |comment|
      matches_location?(violation, comment)
    end
  end

  def matches_location?(violation, comment)
    comment.path == violation.filename && on_same_line?(violation, comment)
  end

  def on_same_line?(violation, comment)
    if comment.position
      comment.position == violation.patch_position
    else
      comment.original_position == violation.patch_position
    end
  end
end
