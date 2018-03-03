# frozen_string_literal: true

class SanitizeIniFile
  static_facade :call

  def initialize(config)
    @config = config
  end

  def call
    lines_without_comments.
      map { |line| normalize_line(line) }.
      join
  end

  private

  def normalize_line(line)
    case line.rstrip
    when /.+=$/
      line.rstrip + " "
    when /^\s+.+,$/
      line.strip
    when /^\s+.+$/
      line.lstrip
    else
      line
    end
  end

  def lines_without_comments
    @config.lines.
      map { |line| line.gsub(/\s*#.*$/, "") }.
      reject { |line| line.strip.blank? }
  end
end
