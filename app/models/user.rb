class User < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  has_many :memberships, dependent: :destroy
  has_many :repos, through: :memberships
  has_many :builds, through: :repos
  has_many :subscriptions
  has_many :subscribed_repos, through: :subscriptions, source: :repo

  validates :username, presence: true

  before_create :generate_remember_token

  delegate :current_plan, :next_plan, :previous_plan, to: :plan_selector

  def plan_upgrade?
    plan_selector.upgrade?
  end

  def current_plan_price
    current_plan.price
  end

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

  def has_marketplace_repos?
    repos.joins(:owner).where.not(
      owners: { marketplace_plan_id: nil },
    ).any?
  end

  def billable_email
    payment_gateway_customer.email
  end

  def has_repos_with_missing_information?
    repos.where("in_organization IS NULL OR private IS NULL").count > 0
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

  def has_access_to_private_repos?
    if token_scopes
      token_scopes.split(",").include? "repo"
    else
      false
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

  private

  def crypt
    secret_key_base = Rails.application.secrets.secret_key_base
    ActiveSupport::MessageEncryptor.new(secret_key_base[0, 32], secret_key_base)
  end

  def payment_gateway_customer
    @payment_gateway_customer ||= PaymentGatewayCustomer.new(self)
  end

  def plan_selector
    @_plan_selector ||= PlanSelector.new(self)
  end

  def generate_remember_token
    self.remember_token = SecureRandom.hex(20)
  end
end
