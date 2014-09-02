class CommentingPolicy
  pattr_initialize :pull_request

  def allowed_for?(violation)
    in_review?(violation.line) && unreported_violation_messages(violation).any?
  end

  private

  def in_review?(line)
    pull_request.opened? || pull_request.head_includes?(line)
  end

  def unreported_violation_messages(violation)
    violation.messages - existing_violation_messages(violation)
  end

  def existing_violation_messages(violation)
    previous_comments_on_line(violation).map(&:body).
      flat_map { |body| body.split("<br>") }
  end

  def previous_comments_on_line(violation)
    existing_comments.select do |comment|
      comment.path == violation.filename &&
        comment.original_position == violation.line.patch_position
    end
  end

  def existing_comments
    @existing_comments ||= pull_request.comments
  end
end
