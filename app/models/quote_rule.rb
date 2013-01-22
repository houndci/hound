class QuoteRule < Rule
  def violated?
    non_interpolating_double_quotes = /"(?:(?!#\{).)*"/

    has?(non_interpolating_double_quotes)
  end
end
