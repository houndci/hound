# frozen_string_literal: true
class ReviewBody
  MAX_BODY_LENGTH = 65536
  SUMMARY_LENGTH = 80
  LINE_DELIMITER = "<br>"
  HEADER = "Some files could not be reviewed due to errors:"
  DETAILS_FORMAT = "<details><summary>%s</summary><pre>%s</pre></details>"

  def initialize(errors)
    @errors = errors
  end

  def to_s
    if errors.any?
      error_details = errors.map { |error| build_error_details(error) }
      [HEADER].concat(error_details).join
    else
      ""
    end
  end

  private

  attr_reader :errors

  def build_error_details(error)
    summary = error_summary(error)
    details = error[0...(allowed_error_length - summary.length)].
      lines.
      map(&:rstrip).
      join(LINE_DELIMITER)

    sprintf(DETAILS_FORMAT, summary, details)
  end

  def error_summary(error)
    error.lines.first.strip.truncate(SUMMARY_LENGTH)
  end

  def allowed_error_length
    (MAX_BODY_LENGTH - formatting_characters_size) / errors.size
  end

  def formatting_characters_size
    HEADER.length + all_detail_formats_length + all_lines_delimiters_length
  end

  def all_detail_formats_length
    DETAILS_FORMAT.size * errors.size
  end

  def all_lines_delimiters_length
    (errors.flat_map(&:lines).size - errors.size) * LINE_DELIMITER.length
  end
end
