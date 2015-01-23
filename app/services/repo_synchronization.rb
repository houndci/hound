class RepoSynchronization
  ORGANIZATION_TYPE = 'Organization'

  pattr_initialize :user, :github_token
  attr_reader :user

  def api
    @api ||= GithubApi.new(github_token)
  end

  def start
    update_user_repos_from_api
    deactivate_orphaned_repos
  end

  private

  def user_repos
    user.repos
  end

  def deactivate_orphaned_repos
    user_repos.each do |repo|
      if repo_not_visible_to_anyone?(repo)
        deactivate_repo(repo)
      end
    end
  end

  def deactivate_repo(repo)
    repo.deactivate
    repo.memberships.destroy_all
    if repo.subscription
      RepoSubscriber.unsubscribe(repo, user)
    end
  end

  def api_repos
    @api_repos ||= api.repos.map do |resource|
      find_or_create_repo(resource)
    end
  end

  def update_user_repos_from_api
    api_repos.each do |repo|
      unless user_repos.include?(repo)
        user.repos << repo
      end
    end
  end

  def repo_not_visible_to_anyone?(repo)
    !api_repos.include?(repo) && repo.memberships.count == 1
  end

  def find_or_create_repo(resource)
    attributes = repo_attributes(resource.to_hash)
    Repo.find_or_create_with(attributes)
  end

  def repo_attributes(attributes)
    {
      private: attributes[:private],
      github_id: attributes[:id],
      full_github_name: attributes[:full_name],
      in_organization: attributes[:owner][:type] == ORGANIZATION_TYPE
    }
  end
end
