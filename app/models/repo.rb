class Repo < ApplicationRecord
  belongs_to :owner
  has_one :subscription
  has_many :builds, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :github_id, uniqueness: true, presence: true

  def self.active
    where(active: true)
  end

  def self.find_or_create_with(attributes)
    repo = find_by(github_id: attributes[:github_id]) ||
      find_by(name: attributes[:name]) ||
      Repo.new

    begin
      repo.update!(attributes)
    rescue ActiveRecord::RecordInvalid => error
      report_update_failure(error, attributes)
    end

    repo
  end

  def activate
    update(active: true)
  end

  def deactivate
    update(active: false)
  end

  def stripe_subscription_id
    if subscription
      subscription.stripe_subscription_id
    end
  end

  def total_violations
    builds.sum(:violations_count)
  end

  def remove_membership(user)
    users.destroy(user)
  end

  def users_with_token
    users.where.not(token: nil)
  end

  def public?
    !private?
  end

  private

  def organization
    name && name.split("/").first
  end

  def self.report_update_failure(error, attributes)
    Raven.capture_exception(
      error,
      extra: {
        github_id: attributes[:github_id],
        name: attributes[:name],
      }
    )
  end
  private_class_method :report_update_failure
end
