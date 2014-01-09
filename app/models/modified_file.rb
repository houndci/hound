class ModifiedFile
  def initialize(file, pull_request)
    @file = file
    @pull_request = pull_request
  end

  def relevant_line?(line_number)
    modified_line_numbers.include?(line_number)
  end

  def filename
    @file.filename
  end

  def removed?
    @file.status == 'removed'
  end

  def ruby?
    filename.match(/.*\.rb$/)
  end

  def source
    Rubocop::SourceParser.parse(contents)
  end

  def line(line_number)
    source.lines[line_number - 1]
  end

  private

  def contents
    @contents ||= begin
      unless removed?
        contents = @pull_request.file_contents(filename)
        Base64.decode64(contents.content)
      end
    end
  end

  def modified_line_numbers
    @modified_line_numbers ||= patch.modified_line_numbers
  end

  def patch
    DiffPatch.new(@file.patch)
  end
end
