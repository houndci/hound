class Patch
  RANGE_INFORMATION_LINE = /^@@ .+\+(?<line_number>\d+),/
  MODIFIED_LINE = /^\+(?!\+|\+)/
  NOT_REMOVED_LINE = /^[^-]/

  def initialize(body)
    @body = body || ''
  end

  def changed_lines
    line_number = 0
    lines.
      each_with_object({}).
      each_with_index do |(content, hash), patch_position|
      case content
      when RANGE_INFORMATION_LINE
        line_number = Regexp.last_match[:line_number].to_i
      when MODIFIED_LINE
        line = Line.new(
          content: content,
          number: line_number,
          patch_position: patch_position
        )
        hash[line_number] = line
        line_number += 1
      when NOT_REMOVED_LINE
        line_number += 1
      end
    end
  end

  private

  def lines
    @body.each_line
  end
end
