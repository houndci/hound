class CommitFile
  pattr_initialize :file, :commit

  def filename
    file.filename
  end

  def content
    @content ||= begin
      unless removed?
        commit.file_content(filename)
      end
    end
  end

  def removed?
    file.status == "removed"
  end

  def modified_line_at(line_number)
    modified_lines.detect do |modified_line|
      modified_line.line_number == line_number
    end
  end

  private

  def modified_lines
    @modified_lines ||= patch.additions
  end

  def patch
    Patch.new(file.patch)
  end
end
