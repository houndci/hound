require 'open-uri'

class GitDiff
  def initialize(patch)
    @patch = patch
  end

  def additions
    @additions ||= @patch.lines.inject([]) do |result, line|
      if line_of_addition?(line)
        result << sanitize_line(line)
      end

      result
    end
  end

  private

  def line_of_addition?(line)                
    !line.start_with?('+++') && line.start_with?('+')
  end

  def sanitize_line(text)
    text.sub(/^\+/, '').strip
  end
end

