class Build < ActiveRecord::Base
  belongs_to :repo

  before_create :generate_uuid

  validates :repo, presence: true

  serialize :violations, Array

  def status
    if violations.any?
      'failed'
    else
      'passed'
    end
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
