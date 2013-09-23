class MethodParenRule < Rule
  EMPTY_PARENS = /\(\)/
  MISSING_PARENS = /^def \w+ /
  METHOD_DEFINITION = /^def /

  def violated?(text)
    if text =~ METHOD_DEFINITION
      text =~ MISSING_PARENS || text =~ EMPTY_PARENS
    else
      false
    end
  end
end
