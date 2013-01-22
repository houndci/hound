class BracketRule < Rule
  def satisfied?
    whitespace_before = /\[\s+/
    whitespace_after = /\s+\]/

    does_not_have?(whitespace_before) && does_not_have?(whitespace_after)
  end
end
