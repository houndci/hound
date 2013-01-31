class WhitespaceRule < Rule
  def violated?(text)
    trailing_whitespace = /\s$/
    text =~ trailing_whitespace
  end
end
