module StyleGuide
  class Go < Base
    def violations_in_file(file)
      Golint.lint(file.content).map do |violation|
        Violation.new(file, violation.line, violation.comment)
      end
    end
  end
end
