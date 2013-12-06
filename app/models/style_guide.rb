require 'rubocop'

class StyleGuide
  attr_reader :violations

  RULES = [
    Rubocop::Cop::Style::Tab,
    Rubocop::Cop::Style::TrailingWhitespace
  ]

  def initialize(files)
    @files = files
    @violations = []
  end

  def check
    @files.each do |file|
      RULES.each do |rule|
        check_for_violations(file, rule)
      end
    end
  end

  private

  def check_for_violations(file, rule)
    cop = rule.new
    source = Rubocop::SourceParser.parse(file.contents)

    cop.investigate(source)
    cop.offences.each do |offence|
      if file.modified_line_numbers.include?(offence.line)
        report_violation(source, offence)
      end
    end
  end

  def report_violation(source, offence)
    line_of_code = source.lines[offence.line - 1]
    @violations << [offence.line, line_of_code, offence.message]
  end
end
