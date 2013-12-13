class PullRequestFile
  attr_reader :contents

  def initialize(file, contents)
    @file = file
    @contents = contents
  end

  def modified_line_numbers
    @modified_line_numbers ||= DiffPatch.new(@file.patch).modified_line_numbers
  end

  def filename
    @file.filename
  end
end
