class HashSyntaxRule < Rule
  def violated?(text)
    uses_non_preferred_hash_syntax?(text)
  end

  private

  def uses_non_preferred_hash_syntax?(text)
    hashrocket_after_symbol = /(\b|\s):\w.*=>/

    text =~ hashrocket_after_symbol
  end
end
