class CommentingPolicy
  def comment_permitted?(pull_request, previous_comments_on_line, violation)
    existing_messages = previous_comments_on_line.map(&:body)

    in_review?(pull_request, violation.line) &&
      violation_not_previously_reported?(
        violation.messages,
        existing_messages
      )
  end

  private

  def in_review?(pull_request, line)
    pull_request.opened? || pull_request.head_includes?(line)
  end

  def violation_not_previously_reported?(new_messages, existing_messages)
    (new_messages & existing_messages).empty?
  end
end
