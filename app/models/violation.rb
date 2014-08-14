# Hold file, line, and violation message values.
# Built by style guides.
# Printed by Commenter.
class Violation < Struct.new(:filename, :line, :messages)
  def line_number
    line.line_number
  end
end
