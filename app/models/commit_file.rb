class CommitFile
  attr_reader :filename, :content

  def initialize(filename, content, patch_body)
    @filename = filename
    @content = content
    @patch_body = patch_body
  end

  def line_at(line_number)
    changed_lines.detect { |line| line.number == line_number } ||
      UnchangedLine.new
  end

  private

  attr_reader :patch_body

  def changed_lines
    @changed_lines ||= patch.changed_lines
  end

  def patch
    Patch.new(patch_body)
  end
end
