class WhitespaceRule < Rule
  def violated?
    trailing_whitespace = /\s$/

    has?(trailing_whitespace)
  end
end
