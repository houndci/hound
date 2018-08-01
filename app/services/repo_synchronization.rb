class RepoSynchronization
  pattr_initialize :user

  def start
    user.repos.clear

    Repo.transaction do
      repos.each do |resource|
        create_user_membership_from(resource)
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end
  end

  private

  def repos
    if user.installation_ids.any?
      user.installation_ids.flat_map do |installation_id|
        installation_repos(installation_id).map do |repo|
          repo.to_hash.merge(installation_id: installation_id)
        end
      end
    else
      oauth.repos
    end
  end

  def create_user_membership_from(resource)
    repo = CreateRepo.call(resource)
    admin = repo.installation_id.present? || resource[:permissions][:admin]
    user.memberships.create!(repo: repo, admin: admin)
  end

  def oauth
    GitHubApi.new(user.token)
  end

  def installation(installation_id)
    app = GitHubApi.new(AppToken.new.generate)
    token = app.create_installation_token(installation_id)
    GitHubApi.new(token)
  end

  def installation_repos(installation_id)
    installation(installation_id).installation_repos
  rescue Octokit::NotFound => exception
    Raven.user_context(username: user.username)
    Raven.capture_exception(exception)
    []
  end
end
