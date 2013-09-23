class BracketRule < Rule
  def violated?(text)
    whitespace_before = /\[\s+/
    whitespace_after = /\s+\]/
    text =~ whitespace_before || text =~ whitespace_after
  end
end
