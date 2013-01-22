class MethodParenRule < Rule
  EMPTY_PARENS = /\(\)/
  MISSING_PARENS = /^def \w+ /
  METHOD_DEFINITION = /^def /

  def violated?
    if @text =~ METHOD_DEFINITION
      has?(MISSING_PARENS) || has?(EMPTY_PARENS)
    else
      false
    end
  end
end
