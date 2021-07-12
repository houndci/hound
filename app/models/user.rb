class User < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  has_many :memberships, dependent: :destroy
  has_many :repos, through: :memberships
  has_many :builds, through: :repos
  has_many :subscriptions
  has_many :subscribed_repos, through: :subscriptions, source: :repo

  validates :username, presence: true

  before_create :generate_remember_token

  delegate :current_plan, :next_plan, to: :plan_selector

  def next_plan_price
    next_plan.price
  end

  def plan_max
    current_plan.allowance
  end

  def to_s
    username
  end

  def active_repos
    repos.active
  end

  def billable_email
    payment_gateway_customer.email
  end

  def has_active_repos?
    active_repos.count > 0
  end

  def token=(value)
    encrypted_token = crypt.encrypt_and_sign(value)
    write_attribute(:token, encrypted_token)
  end

  def token
    encrypted_token = read_attribute(:token)
    unless encrypted_token.nil?
      crypt.decrypt_and_verify(encrypted_token)
    end
  end

  def payment_gateway_subscription
    @_payment_gateway_subscription ||= payment_gateway_customer.subscription
  end

  def repos_by_activation_ability
    repos.
      order("memberships.admin DESC").
      order(active: :desc).
      order("LOWER(name) ASC")
  end

  def card_exists?
    stripe_customer_id.present?
  end

  def owner_ids
    repos.distinct.pluck(:owner_id)
  end

  def first_available_repo
    if subscriptions.any?
      subscriptions.first.repo
    else
      repos.order([:private, :active]).first
    end
  end

  def marketplace_user?
    plan_selector.marketplace_plan?
  end

  def metered_plan?
    owner.metered_plan?
  end

  def recent_builds
    owner.recent_builds
  end

  def owner
    @_owner ||= begin
      user_as_owner = Owner.find_by(name: username)

      if user_as_owner&.stripe_plan_id.present?
        user_as_owner
      else
        first_available_repo&.owner || user_as_owner
      end
    end
  end

  private

  def crypt
    secret_key_base = Rails.application.secrets.secret_key_base
    ActiveSupport::MessageEncryptor.new(secret_key_base[0, 32], secret_key_base)
  end

  def payment_gateway_customer
    @payment_gateway_customer ||= PaymentGatewayCustomer.new(self)
  end

  def plan_selector
    @_plan_selector ||= PlanSelector.new(owner)
  end

  def generate_remember_token
    self.remember_token = SecureRandom.hex(20)
  end
end
