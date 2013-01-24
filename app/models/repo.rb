class Repo < ActiveRecord::Base
  attr_accessible :github_id, :active

  validates :github_id, uniqueness: true, presence: true

  def self.active_repo_ids_in(ids)
    where(github_id: ids, active: true).pluck(:github_id)
  end

  def self.find_by_github_id(github_id)
    where(github_id: github_id).first || NullRepo.new(github_id: github_id)
  end

  def activate
    update_attribute(:active, true)
  end
end

class NullRepo
  attr_reader :github_id

  def initialize(attributes)
    @github_id = attributes[:github_id]
  end

  def id
    nil
  end

  def activate
    Repo.create(github_id: github_id, active: true)
  end
end
