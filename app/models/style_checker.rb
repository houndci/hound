class StyleChecker
  def initialize(modified_files, custom_config = nil)
    @modified_files = modified_files
    @custom_config = custom_config
  end

  def violations
    file_violations = @modified_files.map do |modified_file|
      FileViolation.new(modified_file.filename, line_violations(modified_file))
    end

    file_violations.select do |file_violation|
      file_violation.line_violations.any?
    end
  end

  private

  def line_violations(modified_file)
    violations = style_guide.violations(modified_file)
    violations = violations_on_changed_lines(modified_file, violations)

    violations.group_by(&:line).map do |line_number, violations|
      message = violations.map(&:message).uniq
      modified_line = modified_file.modified_line_at(line_number)

      LineViolation.new(modified_line, message)
    end
  end

  def violations_on_changed_lines(modified_file, violations)
    violations.select do |violation|
      modified_file.relevant_line?(violation.line)
    end
  end

  def style_guide
    @style_guide ||= StyleGuide.new(@custom_config)
  end
end
