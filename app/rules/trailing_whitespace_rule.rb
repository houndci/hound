class TrailingWhitespaceRule < Rule
  def violated?(source)
    cop.investigate(parse_source(source))
    cop.offences.any?
  end

  private

  def cop
    @cop ||= Rubocop::Cop::Style::TrailingWhitespace.new
  end

  def parse_source(source)
    @source ||= Rubocop::SourceParser.parse(source)
  end
end
