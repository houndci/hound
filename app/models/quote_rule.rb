class QuoteRule < Rule
  def satisfied?
    (@text =~ /"(?:(?!#\{).)*"/).nil?
  end
end
