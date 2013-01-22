class QuoteRule < Rule
  def satisfied?
    non_interpolating_double_quotes = /"(?:(?!#\{).)*"/

    does_not_have?(non_interpolating_double_quotes)
  end
end
