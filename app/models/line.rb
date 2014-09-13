class Line
  attr_reader :number, :patch_position

  def initialize(number:, content:, patch_position:)
    @number = number
    @content = content
    @patch_position = patch_position
  end

  def changed?
    true
  end
end
