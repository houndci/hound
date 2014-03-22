class Patch
  RANGE_INFORMATION_LINE = /^@@ .+\+(?<line_number>\d+),/
  MODIFIED_LINE = /^\+(?!\+|\+)/
  NOT_REMOVED_LINE = /^[^-]/

  Line = Struct.new(:content, :line_number, :patch_position)

  attr_reader :additions

  def initialize(body)
    @body = body
    @additions = []
    parse
  end

  private

  def parse
    line_number = 0

    lines.each_with_index do |content, patch_position|
      case content
      when RANGE_INFORMATION_LINE
        line_number = Regexp.last_match[:line_number].to_i
      when MODIFIED_LINE
        @additions << Line.new(content, line_number, patch_position)
        line_number += 1
      when NOT_REMOVED_LINE
        line_number += 1
      end
    end
  end

  def lines
    @body.lines
  end
end
