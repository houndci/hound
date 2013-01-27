class Repo < ActiveRecord::Base
  attr_accessor :name

  attr_accessible :name, :github_id, :active

  validates :github_id, uniqueness: true, presence: true

  scope :active, where(active: true)

  def activate
    update_attribute(:active, true)
  end

  def deactivate
    update_attribute(:active, false)
  end
end
