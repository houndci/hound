class Repo < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :memberships
  has_many :users, through: :memberships
  has_many :builds

  validates :name, presence: true
  validates :full_github_name, presence: true
  validates :github_id, uniqueness: true, presence: true

  scope :active, -> { where(active: true) }

  def activate
    update_attribute(:active, true)
  end

  def deactivate
    update_attributes(active: false, hook_id: nil)
  end

  def github_token
    users.first.github_token
  end
end  
