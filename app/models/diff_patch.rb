class DiffPatch
  RANGE_INFORMATION_LINE = /^@@ .+\+(?<line_number>\d+),/
  MODIFIED_LINE = /^\+(?!\+|\+)/
  NOT_REMOVED_LINE = /^[^-]/

  def initialize(patch)
    @patch = patch
  end

  def modified_lines
    line_number = 0
    @patch.lines.each_with_index.inject([]) do |modified_lines, (line, position)|
      case line
      when RANGE_INFORMATION_LINE
        line_number = Regexp.last_match[:line_number].to_i
      when MODIFIED_LINE
        modified_lines << ModifiedLine.new(line, line_number, position)
        line_number += 1
      when NOT_REMOVED_LINE
        line_number += 1
      end

      modified_lines
    end
  end
end
