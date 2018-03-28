class Owner < ApplicationRecord
  has_many :repos

  def self.upsert(github_id:, name:, organization:)
    find_or_initialize_by(github_id: github_id).tap do |owner|
      owner.name = name
      owner.organization = organization
      owner.save!
    end
  rescue ActiveRecord::RecordNotUnique => exception
    capture_exception(exception, name, github_id)
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
      hound_config: hound_config,
      name: linter_name,
      owner: MissingOwner.new,
    ).content
  end

  def hound_config_content
    hound_config.content
  end

  private

  def hound_config
    @_hound_config ||= BuildOwnerHoundConfig.call(self)
  end

  def self.capture_exception(exception, name, github_id)
    Raven.capture_exception(
      exception,
      extra: {
        github_id: github_id,
        name: name,
      },
    )
  end
  private_class_method :capture_exception
end
