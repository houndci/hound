class ParenthesisRule < Rule
  WHITESPACE_BEFORE = '\(\s+'
  WHITESPACE_AFTER = '\s+\)'

  def satisfied?
    (@text =~ /(#{WHITESPACE_AFTER}|#{WHITESPACE_BEFORE})/).nil?
  end
end
