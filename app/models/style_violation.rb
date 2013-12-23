class StyleViolation
  attr_reader :filename

  def initialize(filename, lines, line_numbers, violations)
    @filename = filename
    @lines = lines
    @line_numbers = line_numbers
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
    allowed_violations.group_by { |violation| violation.line }
  end

  def allowed_violations
    @violations.select { |violation| modified_line_number?(violation.line) }
  end

  def line_of_code(line_number)
    @lines[line_number - 1]
  end

  def modified_line_number?(line_number)
    @line_numbers.include?(line_number)
  end
end
