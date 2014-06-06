class Commenter
  def comment_on_violations(file_violations, pull_request)
    file_violations.each do |file_violation|
      file_violation.line_violations.each do |line_violation|
        line = line_violation.line
        comment = Comment.new(line)

        if commenting_policy.comment_permitted?(pull_request, comment)
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
end
