# frozen_string_literal: true

class CommentingPolicy
  COMMENT_LINE_DELIMITER = "<br>"

  pattr_initialize :comments

  def comment_on?(violation)
    unreported_violation_messages(violation).any?
  end

  def outdated_comments(found_violations)
    comments.select do |comment|
      comment.user.type == "Bot" &&
        comment.user.login.start_with?("hound") &&
        outdated_comment?(comment, found_violations)
    end
  end

  private

  def outdated_comment?(comment, violations)
    violations.none? do |violation|
      matches_location?(violation, comment) &&
        matches_messages?(violation, comment)
    end
  end

  def unreported_violation_messages(violation)
    violation.messages - existing_comment_messages(violation)
  end

  def existing_comment_messages(violation)
    existing_comments_on_line(violation).flat_map do |comment|
      comment_messages(comment)
    end
  end

  def comment_messages(comment)
    comment.body.split(COMMENT_LINE_DELIMITER)
  end

  def existing_comments_on_line(violation)
    comments.select do |comment|
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

  def matches_messages?(violation, comment)
    (comment_messages(comment) & violation.messages).any?
  end
end
