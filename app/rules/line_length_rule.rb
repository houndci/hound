class LineLengthRule < Rule
  def violated?(text)
    text.length > 80
  end
end
