class Owner < ApplicationRecord
  has_many :repos

  def self.upsert(github_id:, name:, organization:)
    owner = find_by(github_id: github_id) || find_by(name: name) || Owner.new
    owner.update!(
      github_id: github_id,
      name: name,
      organization: organization,
    )
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
