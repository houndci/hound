class Repo < ActiveRecord::Base
  has_many :builds
  has_many :memberships, dependent: :destroy
  belongs_to :owner
  has_one :subscription
  has_many :users, through: :memberships

  alias_attribute :name, :full_github_name

  delegate :type, :price, to: :plan, prefix: true
  delegate :price, to: :subscription, prefix: true

  validates :full_github_name, uniqueness: true, presence: true
  validates :github_id, uniqueness: true, presence: true

  def self.active
    where(active: true)
  end

  def self.find_or_create_with(attributes)
    repo = find_by(full_github_name: attributes[:full_github_name]) ||
      find_by(github_id: attributes[:github_id]) ||
      Repo.new

    begin
      repo.update!(attributes)
    rescue ActiveRecord::RecordInvalid => error
      report_update_failure(error, attributes)
    end

    repo
  end

  def self.find_and_update(github_id, repo_name)
    repo = find_by(github_id: github_id)

    if repo && repo.full_github_name != repo_name
      repo.update(full_github_name: repo_name)
    end

    repo
  end

  def activate
    update(active: true)
  end

  def deactivate
    update(active: false)
  end

  def plan
    Plan.new(self)
  end

  def stripe_subscription_id
    if subscription
      subscription.stripe_subscription_id
    end
  end

  def bulk?
    BulkCustomer.where(org: organization).any? ||
      Hound::EXEMPT_ORGS.split(",").include?(organization)
  end

  def total_violations
    Violation.
      joins(:file_review).
      where(file_reviews: { build_id: build_ids }).
      count
  end

  private

  def organization
    if full_github_name
      full_github_name.split("/").first
    end
  end

  def self.report_update_failure(error, attributes)
    Raven.capture_exception(
      error,
      extra: {
        github_id: attributes[:github_id],
        full_github_name: attributes[:full_github_name],
      }
    )
  end
  private_class_method :report_update_failure
end
