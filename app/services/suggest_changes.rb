class SuggestChanges
  static_facade :call

  def initialize(violation)
    @violation = violation
    @suggestion = ""
  end

  def call
    violation.messages.each do |message|
      apply_suggestion(message)
      break if suggestion.present?
    end

    messages = violation.messages.join(CommentingPolicy::COMMENT_LINE_DELIMITER)

    if suggestion.blank?
      messages
    else
      messages + "<br>\n```suggestion\n#{suggestion}\n```"
    end
  end

  private

  attr_reader :violation
  attr_accessor :suggestion

  def apply_suggestion(message)
    case message
    when /Trailing whitespace detected/
      self.suggestion = violation.source.gsub(/(.*)\s$/, '\1')
    when /A space is required after ','/
      self.suggestion = violation.source.gsub(/(,)([^ ])/, ', \2')
    when /Put a comma after the last parameter of a multiline method call/
      self.suggestion = violation.source + ","
    when /Missing semicolon/
      self.suggestion = violation.source + ";"
    end
  end
end
