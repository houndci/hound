class Owner < ApplicationRecord
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

  def config_content(linter_name)
    BuildConfig.for(
      hound_config: BuildOwnerHoundConfig.run(self),
      name: linter_name,
      owner: MissingOwner.new,
    ).content
  end
end
