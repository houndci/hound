# Container of unique violations
class Violations
  include Enumerable

  def initialize(*violations)
    @violations = {}
    push(*violations)
  end

  def push(*violations)
    violations.each do |violation|
      identifier = "#{violation.filename}:#{violation.line_number}"

      if @violations[identifier].nil?
        @violations[identifier] = violation
      else
        @violations[identifier].add_messages(violation.messages)
      end
    end

    self
  end

  private

  def each(&block)
    changed_line_violations.each(&block)
  end

  def changed_line_violations
    @violations.values.select(&:on_changed_line?)
  end
end
