class CommentingPolicy
  def comment_permitted?(pull_request, comment)
    pull_request.opened? || pull_request.head_includes?(comment.line)
  end
end
