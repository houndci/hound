class CommitFile
  pattr_initialize :file, :commit

  def filename
    file.filename
  end

  def content
    @content ||= commit.file_content(filename)
  end

  def line_at(line_number)
    changed_lines.detect { |line| line.number == line_number } ||
      UnchangedLine.new
  end

  def repo_name
    commit.repo_name
  end

  def sha
    commit.sha
  end

  def patch_body
    file.patch
  end

  private

  def changed_lines
    @changed_lines ||= patch.changed_lines
  end

  def patch
    Patch.new(file.patch)
  end
end
