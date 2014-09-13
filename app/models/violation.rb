# Hold file, line, and violation message values.
# Built by style guides.
# Printed by Commenter.
class Violation
  attr_reader :line_number, :filename

  def initialize(file, line_number, message)
    @filename = file.filename
    @line = file.line_at(line_number)
    @line_number = line_number
    @messages = [message]
  end

  def add_messages(messages)
    @messages += messages
  end

  def messages
    @messages.uniq
  end

  def patch_position
    @line.patch_position
  end

  def on_changed_line?
    @line.changed?
  end
end
