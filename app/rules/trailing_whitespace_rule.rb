class TrailingWhitespaceRule < Rule
  def violated?(text)
    text =~ /\s\z/
  end
end
