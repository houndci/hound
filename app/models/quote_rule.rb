class QuoteRule
  def initialize(text)
    @text = text
  end

  def violated?
    !satisfied?
  end

  def satisfied?
    (@text =~ /"(?:(?!#\{).)*"/).nil?
  end
end
