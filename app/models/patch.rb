class Patch
  RANGE_INFORMATION_LINE = /^@@ .+\+(?<line_number>\d+),/
  MODIFIED_LINE = /^\+(?!\+|\+)/
  NOT_REMOVED_LINE = /^[^-]/

  Line = Struct.new(:content, :line_number, :patch_position)

  def initialize(body)
    @body = body
  end

  def additions
    line_number = 0

    lines.each_with_index.inject([]) do |additions, (content, patch_position)|
      case content
      when RANGE_INFORMATION_LINE
        line_number = Regexp.last_match[:line_number].to_i
      when MODIFIED_LINE
        additions << Line.new(content, line_number, patch_position)
        line_number += 1
      when NOT_REMOVED_LINE
        line_number += 1
      end

      additions
    end
  end

  private

  def lines
    @body.lines
  end
end
