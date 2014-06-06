class LineViolation < Struct.new(:line, :messages)
  def line_number
    line.line_number
  end
end
