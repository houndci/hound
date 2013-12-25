class ModifiedFile
  attr_reader :filename, :contents

  def initialize(filename, contents, line_numbers)
    @filename = filename
    @contents = contents
    @line_numbers = line_numbers
  end

  def relevant_line?(line_number)
    @line_numbers.include?(line_number)
  end
end
