class Build < ActiveRecord::Base
  belongs_to :repo

  before_create :generate_uuid

  validates :repo, presence: true

  serialize :violations, Array

  def status
    violations.any? ? 'failed' : 'passed'
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
