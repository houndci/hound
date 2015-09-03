class CommitFile
  attr_reader :filename, :commit, :patch

  def initialize(filename:, commit:, patch:)
    @filename = filename
    @commit = commit
    @patch = patch
  end

  def content
    commit.file_content(filename)
  end

  def line_at(line_number)
    changed_lines.detect { |line| line.number == line_number } ||
      UnchangedLine.new
  end

  private

  def changed_lines
    @changed_lines ||= Patch.new(patch).changed_lines
  end
end
