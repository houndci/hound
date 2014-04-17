class Repo < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
  has_many :builds

  validates :full_github_name, presence: true
  validates :github_id, uniqueness: true, presence: true

  scope :active, -> { where(active: true) }

  def deactivate
    update_attributes(active: false, hook_id: nil)
  end

  def update_changed_attributes(new_attributes)
    new_full_github_name = new_attributes[:full_name]

    if full_github_name != new_full_github_name
      update_attributes(full_github_name: new_full_github_name)
    end
  end
end
