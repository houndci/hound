class CommitFile
  attr_reader :filename, :content, :patch, :pull_request_number, :sha

  def initialize(filename:, content:, patch:, pull_request_number:, sha:)
    @filename = filename
    @content = content
    @patch = patch
    @pull_request_number = pull_request_number
    @sha = sha
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
