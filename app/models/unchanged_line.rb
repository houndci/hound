class UnchangedLine
  def initialize(*)
  end

  def patch_position
    -1
  end

  def number
    0
  end

  def changed?
    false
  end
end
