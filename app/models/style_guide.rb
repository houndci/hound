class StyleGuide
  attr_accessor :violations

  def initialize
    @violations = []
  end

  # def check(lines)
  #   lines.each do |line|
  #     rules.each do |rule|
  #       rule_instance = rule.new
  #       check_rule(rule_instance, line)
  #     end
  #   end
  # end

  def check(files)
    files.each do |file|
      source = Rubocop::SourceParser.parse(file)
      cop = Rubocop::Cop::Style::TrailingWhitespace.new
      cop.investigate(source)
      # violations += cop.offences
      cop.offences.each do |offence|
        violations << ['TrailingWhitespace', offence.line]
      end
    end
  end

  private

  def check_rule(rule, line)
    if rule.violated?(line)
      violations << [rule.class.name, line]
    end
  end

  def rules
    [
      # IndentationRule,
      # LineLengthRule,
      TrailingWhitespaceRule
      # CommaRule,
      # BraceRule,
      # ParenRule,
      # BracketRule,
      # QuoteRule,
      # MethodParenRule
    ]
  end
end
