class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :memberships
  has_many :repos, through: :memberships
  has_many :subscriptions

  validates :github_username, presence: true

  before_create :generate_remember_token

  def to_s
    github_username
  end

  def github_repo(github_id)
    repos.where(github_id: github_id).first
  end

  def create_github_repo(attributes)
    repos.create(attributes)
  end

  def has_repos_with_missing_information?
    repos.where("in_organization IS NULL OR private IS NULL").count > 0
  end

  private

  def generate_remember_token
    self.remember_token = SecureRandom.hex(20)
  end
end
