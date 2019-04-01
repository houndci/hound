class RepoSynchronization
  pattr_initialize :user

  def start
    user.repos.clear

    Repo.transaction do
      github_repos.each do |github_repo|
        create_user_membership_from(github_repo)
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end
  end

  private

  def github_repos
    installation_ids = user_api.user_installations.map(&:id)

    installation_ids.flat_map do |installation_id|
      installation_repos(installation_id.to_s).map do |repo|
        repo.to_hash.merge(installation_id: installation_id)
      end
    end
  end

  def create_user_membership_from(resource)
    repo = CreateRepo.call(resource)
    user.memberships.create!(repo: repo, admin: true)
  end

  def installation_repos(installation_id)
    installation(installation_id).installation_repos
  rescue Octokit::NotFound => exception
    Raven.user_context(username: user.username)
    Raven.capture_exception(exception)
    []
  end

  def installation(installation_id)
    token = app_api.create_installation_token(installation_id)
    GitHubApi.new(token)
  end

  def app_api
    @_app_api ||= GitHubApi.new(AppToken.new.generate)
  end

  def user_api
    GitHubApi.new(user.token)
  end
end
