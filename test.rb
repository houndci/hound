class Test
  def style_check
    'this should be flagged'
  end

  private
  def private_method
    'Private method without an extra blank line should be flagged'
  end
end
