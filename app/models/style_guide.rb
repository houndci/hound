class StyleGuide
  attr_reader :rules
  attr_accessor :violations

  def initialize(rules)
    @rules = rules
    @violations = []
  end

  def check(lines)
    lines.each do |line|
      rules.each do |rule|
        check_rule(rule, line)
      end
    end
  end

  private

  def check_rule(rule, line)
    if rule.violated?(line)
      violations << rule
    end
  end
end
