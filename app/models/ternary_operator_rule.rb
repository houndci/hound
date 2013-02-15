class TernaryOperatorRule < Rule
  def violated?(text)
    ternary_operator = /\?\s.+\s:\s/

    text =~ ternary_operator
  end
end
