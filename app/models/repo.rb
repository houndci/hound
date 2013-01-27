class Repo < ActiveRecord::Base
  attr_accessor :name

  attr_accessible :name, :github_id, :active

  validates :github_id, uniqueness: true, presence: true

  scope :active, where(active: true)

  def self.find_by_github_id_and_user(github_id, user)
    where(user_id: user, github_id: github_id).first ||
      NullRepo.new(user: user, github_id: github_id)
  end

  def activate
    update_attribute(:active, true)
  end

  def deactivate
    update_attribute(:active, false)
  end
end
