class StyleGuide
  attr_accessor :violations

  def initialize
    @violations = []
  end

  def check(lines)
    lines.each do |line|
      rules.each do |rule|
        rule_instance = rule.new
        check_rule(rule_instance, line)
      end
    end
  end

  private

  def check_rule(rule, line)
    if rule.violated?(line)
      violations << rule
    end
  end

  def rules
    [
      BraceRule,
      BracketRule,
      MethodParenRule,
      ParenRule,
      QuoteRule,
      WhitespaceRule
    ]
  end
end
