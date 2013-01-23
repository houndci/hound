class Repo < ActiveRecord::Base
  attr_accessible :github_id, :active

  def self.active_repo_ids_in(ids)
    where(github_id: ids, active: true).map(&:github_id)
  end
end
