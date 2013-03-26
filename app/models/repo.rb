class Repo < ActiveRecord::Base
  attr_accessible :github_id, :active, :full_github_name, :hook_id

  belongs_to :user

  validates :full_github_name, uniqueness: true, presence: true
  validates :github_id, uniqueness: true, presence: true

  scope :active, where(active: true)

  def activate
    update_attribute(:active, true)
  end

  def deactivate
    update_attributes(active: false, hook_id: nil)
  end
end
