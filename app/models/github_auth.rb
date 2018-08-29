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
    # unless repo.installation_id ??
    if repo.installation_id.nil?
      @_user ||= users_with_token.shuffle.detect(-> { hound_user }) do |user|
        can_reach_repository?(user)
      end
    end
  end

  private

  def can_reach_repository?(user)
    if GitHubApi.new(user.token).repository?(repo.name)
      true
    else
      repo.remove_membership(user)
      false
    end
  end

  def hound_user
    User.new(token: Hound::GITHUB_TOKEN)
  end

  def users_with_token
    repo.users_with_token
  end
end
