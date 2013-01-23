class User < ActiveRecord::Base
  attr_accessible :github_username

  has_many :repos

  before_create :generate_remember_token

  def to_s
    github_username
  end

  def active_repo_ids_in(repo_ids)
    active_repos = repos.where(github_id: repo_ids, active: true)
    active_repos.map(&:github_id)
  end

  private

  def generate_remember_token
    self.remember_token = SecureRandom.hex(20)
  end
end
