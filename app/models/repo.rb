class Repo < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :active, :full_github_name, :github_id, :hook_id, :name

  belongs_to :user

  validates :name, presence: true
  validates :full_github_name, uniqueness: { scope: :user_id }, presence: true
  validates :github_id, uniqueness: { scope: :user_id }, presence: true

  scope :active, where(active: true)

  def activate
    update_attribute(:active, true)
  end

  def deactivate
    update_attributes(active: false, hook_id: nil)
  end

  def github_token
    user.github_token
  end
end
