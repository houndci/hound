module StyleGuide
  class Go < Base
    def violations_in_file(file)
      Golint.lint(file.content).map do |violation|
        line = file.line_at(violation.line)

        Violation.new(
          filename: file.filename,
          patch_position: line.patch_position,
          line: line,
          line_number: violation.line,
          messages: [violation.comment]
        )
      end
    end
  end
end
