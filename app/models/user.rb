class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :memberships, dependent: :destroy
  has_many :repos, through: :memberships
  has_many :subscribed_repos, through: :subscriptions, source: :repo
  has_many :subscriptions

  delegate(
    :card_last4,
    to: :payment_gateway_customer
  )

  validates :github_username, presence: true

  before_create :generate_remember_token

  def to_s
    github_username
  end

  def billable_email
    payment_gateway_customer.email
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

  def has_active_repos?
    repos.active.count > 0
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

  private

  def crypt
    secret_key_base = Rails.application.secrets.secret_key_base
    ActiveSupport::MessageEncryptor.new(secret_key_base)
  end

  def payment_gateway_customer
    @payment_gateway_customer ||= PaymentGatewayCustomer.new(self)
  end

  def generate_remember_token
    self.remember_token = SecureRandom.hex(20)
  end
end
