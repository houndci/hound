class ModifiedFile
  def initialize(file, pull_request)
    @file = file
    @pull_request = pull_request
  end

  def relevant_line?(line_number)
    modified_lines.detect do |modified_line|
      modified_line.line_number == line_number
    end
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

  def contents
    @contents ||= begin
      unless removed?
        @pull_request.file_contents(filename)
      end
    end
  end

  def modified_lines
    @modified_lines ||= patch.modified_lines
  end

  private

  def patch
    DiffPatch.new(@file.patch)
  end
end
