class StyleGuideFile
  RULES = [
    Rubocop::Cop::Style::Tab,
    Rubocop::Cop::Style::TrailingWhitespace
  ]

  attr_reader :filename, :contents

  def initialize(filename, contents, modified_line_numbers)
    @filename = filename
    @contents = contents
    @modified_line_numbers = modified_line_numbers
  end

  def violations
    @violations ||= RULES.map { |rule| violations_for_rule(rule) }.flatten
  end

  private

  def violations_for_rule(rule)
    cop = rule.new
    cop.investigate(source)

    offences = cop.offences.select do |offence|
      modified_line_number?(offence.line)
    end

    offences.map do |offence|
      {
        line_number: offence.line,
        code: line_of_code(offence.line),
        message: offence.message
      }
    end
  end

  def line_of_code(line_number)
    source.lines[line_number - 1]
  end

  def modified_line_number?(line_number)
    @modified_line_numbers.include?(line_number)
  end

  def source
    @source ||= Rubocop::SourceParser.parse(@contents)
  end
end
