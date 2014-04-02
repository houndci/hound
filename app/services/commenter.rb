class Commenter
  def comment_on_violations(violations, pull_request)
    violations.each do |file_violation|
      file_violation.line_violations.each do |line_violation|
        modified_line = file_violation.modified_lines.detect do |modified_line|
          modified_line.line_number == line_violation.line_number
        end

        pull_request.add_comment(
          file_violation.filename,
          modified_line.patch_position,
          line_violation.messages.join('<br>')
        )
      end
    end
  end
end
