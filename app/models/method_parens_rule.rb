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
    @text !~ MISSING_PARENS
  end

  def not_empty_parens
    @text !~ EMPTY_PARENS
  end
end
