class WhitespaceRule < Rule
  PADDED_OPERATOR_REGEX = /[\+\<\>\|&*%=]{1,2}/

  def violated?(text)
    trailing_whitespace?(text) ||
      extra_whitespace?(text) ||
      lacks_whitespace_around_operators?(text) ||
      invalid_colon_whitespace?(text)
  end

  private

  def trailing_whitespace?(text)
    text =~ /\s$/
  end

  def extra_whitespace?(text)
    text =~ /\s{2,}/
  end

  def lacks_whitespace_around_operators?(text)
    matches = text.scan(PADDED_OPERATOR_REGEX)
    matches.any? { |matcher| text !~ /\s#{Regexp.escape(matcher)}\s/ }
  end

  def invalid_colon_whitespace?(text)
    text.include?(':') && does_not_match_colon_whitespace?(text)
  end

  def does_not_match_colon_whitespace?(text)
    text !~ /\?.+\s:\s/ && text !~ /[^:\s]:\s/ && text !~ /\S::\S/
  end
end
