class Build < ApplicationRecord
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

  def github_auth
    @_github_auth ||= GitHubAuth.new(repo)
  end

  def review_errors
    file_reviews.where.not(error: [nil, ""]).
      pluck(Arel.sql("DISTINCT error")).
      uniq { |error| error.lines.first }
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
