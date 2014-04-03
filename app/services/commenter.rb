class Commenter
  def comment_on_violations(file_violations, pull_request)
    file_violations.each do |file_violation|
      file_violation.line_violations.each do |line_violation|
        line_with_violation = find_line_with_violation(
          file_violation,
          line_violation
        )

        if pull_request.opened? ||
          pull_request.head_includes?(line_with_violation)
          pull_request.add_comment(
            file_violation.filename,
            line_with_violation.patch_position,
            build_comment_body(line_violation)
          )
        end
      end
    end
  end

  private

  def find_line_with_violation(file_violation, line_violation)
    file_violation.modified_lines.detect do |modified_line|
      modified_line.line_number == line_violation.line_number
    end
  end

  def build_comment_body(line_violation)
    line_violation.messages.join('<br>')
  end
end
