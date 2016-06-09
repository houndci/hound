class Owner < ActiveRecord::Base
  has_many :repos

  def self.upsert(github_id:, name:, organization:)
    owner = find_or_initialize_by(github_id: github_id)
    owner.name = name
    owner.organization = organization
    owner.save!
    owner
  end

  def has_config_repo?
    config_enabled? && config_repo.present?
  end
end
