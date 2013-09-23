class QuoteRule < Rule
  def violated?(text)
    non_interpolating_double_quotes = /"(?:(?!#\{).)*"/
    text =~ non_interpolating_double_quotes
  end
end
