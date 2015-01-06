class CommentingPolicy
  pattr_initialize :pull_request

  def allowed_for?(violation)
    unreported_violation_messages(violation).any?
  end

  private

  def unreported_violation_messages(violation)
    violation.messages - existing_violation_messages(violation)
  end

  def existing_violation_messages(violation)
    previous_comments_on_line(violation).map(&:body).
      flat_map { |body| body.split("<br>") }
  end

  def previous_comments_on_line(violation)
    existing_comments.select do |comment|
      comment.path == violation.filename && on_same_line?(violation, comment)
    end
  end

  def on_same_line?(violation, comment)
    if comment.position
      comment.position == violation.patch_position
    else
      comment.original_position == violation.patch_position
    end
  end

  def existing_comments
    @existing_comments ||= pull_request.comments
  end
end
