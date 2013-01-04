class WhitespaceRule < Rule
  def satisfied?
    (@text =~ /\s$/).nil?
  end
end
