class StyleViolation
  attr_reader :filename

  def initialize(filename, source_lines, violations)
    @filename = filename
    @source_lines = source_lines
    @violations = violations
  end

  def lines
    grouped_violations.map do |line_number, violations|
      {
        line_number: line_number,
        code: line_of_code(line_number),
        messages: violations.map(&:message)
      }
    end
  end

  private

  def grouped_violations
    @violations.group_by { |violation| violation.line }
  end

  def line_of_code(line_number)
    @source_lines[line_number - 1]
  end
end
