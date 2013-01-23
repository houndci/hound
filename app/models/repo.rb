class Repo < ActiveRecord::Base
  attr_accessible :github_id, :active

  validates :github_id, uniqueness: true, presence: true

  def self.active_repo_ids_in(ids)
    where(github_id: ids, active: true).pluck(:github_id)
  end
end
