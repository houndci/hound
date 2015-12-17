# Hold file, line number, and violation message values.
# Built by style guides.
# Printed by Commenter.
class Violation < ActiveRecord::Base
  belongs_to :file_review

  delegate :count, to: :messages, prefix: true
  delegate :filename, to: :file_review

  after_create :increment_build_violations_count

  def add_message(message)
    self[:messages] << message
  end

  def messages
    self[:messages].uniq
  end

  def increment_build_violations_count
    file_review.build.increment!(:violations_count, messages_count)
  end
end
