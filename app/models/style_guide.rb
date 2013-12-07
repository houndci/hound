require 'rubocop'

class StyleGuide
  attr_accessor :violations

  RULES = [
    Rubocop::Cop::Style::TrailingWhitespace
  ]

  def initialize
    @violations = []
  end

  def check(files)
    files.each do |file|
      source = parse_file(file)

      RULES.each do |rule|
        check_for_violations(source, rule)
      end
    end
  end

  private

  def parse_file(file)
    Rubocop::SourceParser.parse(file)
  end

  def check_for_violations(source, rule)
    cop = rule.new
    cop.investigate(source)
    cop.offences.each do |offence|
      violations << [offence.message, offence.line]
    end
  end
end
