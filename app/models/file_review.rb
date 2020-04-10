class FileReview < ApplicationRecord
  belongs_to :build
  has_many :violations, dependent: :destroy

  def build_violation(line, message, source)
    if line.changed?
      violation = find_or_build_violation(line)
      violation.add_message(message)
      violation.patch_position = line.patch_position
      violation.source = source
    end
  end

  def complete
    self.completed_at = Time.current
  end

  def completed?
    completed_at?
  end

  private

  def find_or_build_violation(line)
    violations.detect { |violation| violation.line_number == line.number } ||
      violations.build(line_number: line.number)
  end
end
