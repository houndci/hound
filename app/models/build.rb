class Build < ActiveRecord::Base
  belongs_to :repo
  belongs_to :user
  has_many :file_reviews, dependent: :destroy
  has_many :violations, through: :file_reviews

  before_create :generate_uuid

  validates :repo, presence: true

  delegate :name, to: :repo, prefix: true

  def completed?
    file_reviews.where(completed_at: nil).empty?
  end

  def violation_count
    violations.map(&:messages_count).sum
  end

  def user_token
    (user && user.token) || Hound::GITHUB_TOKEN
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
