class Line < Struct.new(:content, :line_number, :patch_position)
  def ==(other_line)
    content == other_line.content
  end
end
