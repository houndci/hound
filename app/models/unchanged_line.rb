# frozen_string_literal: true

class UnchangedLine
  def initialize(*)
  end

  def patch_position
    -1
  end

  def changed?
    false
  end
end
