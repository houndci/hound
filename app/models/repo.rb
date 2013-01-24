class Repo < ActiveRecord::Base
  attr_accessible :github_id, :active

  validates :github_id, uniqueness: true, presence: true

  def self.active_repo_ids_in(ids)
    where(github_id: ids, active: true).pluck(:github_id)
  end

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

class NullRepo
  attr_reader :user, :github_id

  def initialize(attributes)
    @user = attributes[:user]
    @github_id = attributes[:github_id]
  end

  def id
    nil
  end

  def activate
    user.repos.create(github_id: github_id, active: true)
  end
end
