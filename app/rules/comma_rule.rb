class CommaRule < Rule
  def violated?(text)
    text_includes_comma(text) && text_includes_comma_without_space_after(text)
  end

  private

  def text_includes_comma(text)
    text.include? ','
  end

  def text_includes_comma_without_space_after(text)
    !(text =~ /,\s/)
  end
end
