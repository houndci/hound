class Owner < ApplicationRecord
  has_many :repos

  def self.upsert(github_id:, name:, organization:)
    owner = find_or_initialize_by(github_id: github_id)
    owner.name = name
    owner.organization = organization
    owner.save!
    owner

  rescue ActiveRecord::RecordNotUnique => exception
    Raven.capture_exception(
      exception,
      extra: {
        github_id: github_id,
        name: name,
      },
    )

    raise exception
  end

  def active_private_repos_count
    repos.active.where(private: true).count
  end

  def has_config_repo?
    config_enabled? && config_repo.present?
  end

  def config_content(linter_name)
    BuildConfig.call(
      hound_config: BuildOwnerHoundConfig.call(self),
      name: linter_name,
      owner: MissingOwner.new,
    ).content
  end
end
