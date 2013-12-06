class DiffPatch
  RANGE_INFORMATION = /^@@ .+\+(?<line_number>\d+),/
  MODIFIED_LINE = /^\+(?!\+|\+)(?<code>.*)/

  def initialize(patch)
    @patch = patch
  end

  def modified_line_numbers
    @patch.lines.inject([]) do |line_numbers, line|
      case line
      when RANGE_INFORMATION
        @line_number = Regexp::last_match[:line_number].to_i
      when MODIFIED_LINE
        line_numbers << @line_number
        @line_number += 1
      else
        @line_number += 1
      end

      line_numbers
    end
  end
end
