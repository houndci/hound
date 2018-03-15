# frozen_string_literal: true

class ReviewBody
  MAX_BODY_LENGTH = 65536
  SUMMARY_LENGTH = 80
  HEADER = "Some files could not be reviewed due to errors:"
  DETAILS_FORMAT = "<details>\n<summary>%s</summary>\n<pre>%s</pre>\n</details>"
  FORMAT_PLACEHOLDER_CHARCTERS = 4

  def initialize(errors)
    @errors = errors
  end

  def to_s
    if errors.any?
      output = HEADER
      room_left = MAX_BODY_LENGTH - output.size

      output + build_errors(errors, room_left)
    else
      ""
    end
  end

  private

  attr_reader :errors

  def build_errors(errors, room_left)
    head, *tail = errors
    error_details = "\n" + build_error_details(head, room_left - 1)

    if (room_left - error_details.size) >= 0
      if tail.any?
        error_details + build_errors(tail, room_left - error_details.size)
      else
        error_details
      end
    else
      ""
    end
  end

  def build_error_details(error, room_left)
    summary = error_summary(error)
    allowed_size = room_left -
      (summary.size + DETAILS_FORMAT.size - FORMAT_PLACEHOLDER_CHARCTERS)

    if allowed_size > 0
      sprintf(DETAILS_FORMAT, summary, error[0...allowed_size])
    end
  end

  def error_summary(error)
    error.lines.first.strip.truncate(SUMMARY_LENGTH)
  end
end
