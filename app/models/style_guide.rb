require 'rubocop'

class StyleGuide
  attr_reader :violations

  RULES = [
    Rubocop::Cop::Style::TrailingWhitespace
  ]

  RULES = [
    Rubocop::Cop::Style::TrailingWhitespace
  ]

  def initialize
    @violations = []
  end

  def check(files)
    files.each do |file|
      RULES.each do |rule|
        check_for_violations(file, rule)
      end
    end
  end

  private

  def check_for_violations(file, rule)
    cop = rule.new
    source = Rubocop::SourceParser.parse(file)

    cop.investigate(source)
    cop.offences.each do |offence|
      report_violation(source, offence)
    end
  end

  def report_violation(source, offence)
    line_of_code = source.lines[offence.line - 1]
    @violations << [offence.line, line_of_code, offence.message]
  end
end
