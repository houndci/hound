class WhitespaceRule < Rule
  def satisfied?
    trailing_whitespace = /\s$/

    does_not_have?(trailing_whitespace)
  end
end
