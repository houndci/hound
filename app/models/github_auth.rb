class GitHubAuth
  attr_private_initialize :repo

  def token
    @_token ||= begin
      if repo.installation_id
        app = GitHubApi.new(AppToken.new.generate)
        app.create_installation_token(repo.installation_id)
      else
        user.token
      end
    end
  end

  def user
    if repo.installation_id.nil?
      @_user ||= users_with_token.shuffle.detect(-> { hound_user }) do |user|
        has_pr_status_permissions?(user)
      end
    end
  end

  private

  def has_pr_status_permissions?(user)
    GitHubApi.new(user.token).statuses(repo.name, "master")
    true
  rescue Octokit::NotFound
    repo.remove_membership(user)
    false
  end

  def hound_user
    User.new(token: Hound::GITHUB_TOKEN)
  end

  def users_with_token
    repo.users_with_token
  end
end
