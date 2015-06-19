class Build < ActiveRecord::Base
  belongs_to :repo
  has_many :file_reviews, dependent: :destroy
  has_many :violations, through: :file_reviews

  before_create :generate_uuid

  validates :repo, presence: true

  def completed?
    file_reviews.where(completed_at: nil).empty?
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
