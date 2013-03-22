class Repo < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :name, :full_github_name, :github_id

  belongs_to :user

  validates :name, presence: true
  validates :full_github_name, presence: true
  validates :github_id, uniqueness: true, presence: true

  scope :active, where(active: true)

  def activate
    update_attribute(:active, true)
  end

  def deactivate
    update_attribute(:active, false)
  end
end
