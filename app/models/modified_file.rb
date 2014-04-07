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

  def renamed?
    @file.status == 'renamed'
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
    @modified_lines ||= patch.additions
  end

  def modified_line_at(line_number)
    modified_lines.detect do |modified_line|
      modified_line.line_number == line_number
    end
  end

  private

  def patch
    Patch.new(@file.patch)
  end
end
