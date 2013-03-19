class Repo < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :github_id, :active

  validates :github_id, uniqueness: true, presence: true

  scope :active, where(active: true)

  def activate
    update_attribute(:active, true)
  end

  def deactivate
    update_attribute(:active, false)
  end
end
