class Repo < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
  has_many :builds

  has_one :subscription

  validates :full_github_name, presence: true
  validates :github_id, uniqueness: true, presence: true

  scope :active, -> { where(active: true) }

  def deactivate
    update_attributes(active: false, hook_id: nil)
  end

  def price
    Subscription::PLANS.fetch(plan.to_sym)
  end

  def plan
    if private?
      if in_organization?
        "organization"
      else
        "personal"
      end
    else
      "free"
    end
  end

  def self.find_or_create_with(attributes)
    repo = where(github_id: attributes[:github_id]).first_or_initialize
    repo.update_attributes(attributes)
    repo
  end

  def stripe_subscription_id
    subscription ? subscription.stripe_subscription_id : nil
  end
end
