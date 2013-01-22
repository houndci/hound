class MethodParensRule < Rule
  EMPTY_PARENS = /\(\)/
  MISSING_PARENS = /^def \w+ /
  METHOD_DEFINITION = /^def /

  def satisfied?
    if @text =~ METHOD_DEFINITION
      not_missing_parens && not_empty_parens
    else
      true
    end
  end

  private

  def not_missing_parens
    does_not_have?(MISSING_PARENS)
  end

  def not_empty_parens
    does_not_have?(EMPTY_PARENS)
  end
end
