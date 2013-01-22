class BracketRule < Rule
  def violated?
    whitespace_before = /\[\s+/
    whitespace_after = /\s+\]/

    has?(whitespace_before) || has?(whitespace_after)
  end
end
