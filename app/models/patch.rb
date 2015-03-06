class Patch
  RANGE_INFORMATION_LINE = /^@@ .+\+(?<line_number>\d+),/
  MODIFIED_LINE = /^\+(?!\+|\+)/
  NOT_REMOVED_LINE = /^[^-]/

  def initialize(body)
    @body = body || ''
  end

  def changed_lines
    line_number = 0

    lines.each_with_index.inject([]) do |lines, (content, patch_position)|
      case content
      when RANGE_INFORMATION_LINE
        line_number = Regexp.last_match[:line_number].to_i
      when MODIFIED_LINE
        line = Line.new(
          content: content,
          number: line_number,
          patch_position: patch_position
        )
        lines << line
        line_number += 1
      when NOT_REMOVED_LINE
        line_number += 1
      end

      lines
    end
  end

  private

  def lines
    @body.lines
  end
end
