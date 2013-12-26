class ModifiedFile
  attr_reader :filename, :contents

  def initialize(options = {})
    @filename = options.fetch(:filename)
    @contents = options.fetch(:contents)
    @patch = options.fetch(:patch)
  end

  def line_numbers
    @line_numbers ||= DiffPatch.new(@patch).modified_line_numbers
  end
end
