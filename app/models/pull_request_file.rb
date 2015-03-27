class PullRequestFile
  rattr_initialize :filename, :content, :patch_body

  def line_at(line_number)
    changed_lines.detect { |line| line.number == line_number } ||
      UnchangedLine.new
  end

  private

  def changed_lines
    @changed_lines ||= patch.changed_lines
  end

  def patch
    Patch.new(patch_body)
  end
end
