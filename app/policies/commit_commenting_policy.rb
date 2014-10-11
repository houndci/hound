class CommitCommentingPolicy
  pattr_initialize :commit

  def allowed_for?(message)
    !existing_messages.include?(message)
  end

  private

  def existing_messages
    existing_comments.map(&:body).flat_map { |body| body.split("<br>") }
  end

  def existing_comments
    @existing_comments ||= commit.comments
  end
end
