class StyleChecker
  RULES = [
    Rubocop::Cop::Style::Tab,
    Rubocop::Cop::Style::TrailingWhitespace
  ]

  def initialize(files)
    @files = files
  end

  def violations
    @violations ||= @files.map { |file| style_violations(file) }.
      select { |style_violation| style_violation.lines.any? }
  end

  private

  def style_violations(file)
    source = Rubocop::SourceParser.parse(file.contents)
    offences = RULES.map { |rule| offences(rule, source) }.flatten

    StyleViolation.new(file.filename, source.lines, file.line_numbers, offences)
  end

  def offences(rule, source)
    cop = rule.new
    cop.investigate(source)
    cop.offences
  end
end
