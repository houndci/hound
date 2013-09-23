class IndentationRule < Rule
  def violated?(text)
    string_starts_with_tabs(text)
  end

  private

  def string_starts_with_tabs(text)
    text =~ /\A\t+/
  end
end
