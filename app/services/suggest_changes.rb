class SuggestChanges
  static_facade :call


  def initialize(violation)
    @violation = violation
    @suggestion = ""
  end

  def call
    messages = violation.messages.join(CommentingPolicy::COMMENT_LINE_DELIMITER)

    violation.messages.each do |message|
      apply_suggestion(message)
    end

    if suggestion.present?
      messages + "\n<br>\n```suggestion\n#{suggestion}\n```"
    else
      messages
    end
  end

  private

  attr_reader :violation
  attr_accessor :suggestion

  def apply_suggestion(message)
    case message
    when "Missing semicolon semi"
      self.suggestion = violation.source << ";"
    end
  end
end
