class Commenter
  def comment_on_violations(file_violations, pull_request)
    file_violations.each do |file_violation|
      file_violation.line_violations.each do |line_violation|
        line     = line_violation.line
        position = "`#{file_violation.filename}:#{line.line_number}`"

        if pull_request.opened? || pull_request.head_includes?(line)
          pull_request.add_comment(
            file_violation.filename,
            line.patch_position,
            [position, line_violation.messages].join('<br>')
          )
        end
      end
    end
  end
end
