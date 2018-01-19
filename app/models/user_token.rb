class UserToken
  attr_private_initialize :repo

  def token
    user.token
  end

  def user
    @user ||= users_with_token.sample || user_with_default_token
  end

  private

  def user_with_default_token
    User.new(token: Hound::GITHUB_TOKEN)
  end

  def users_with_token
    repo.users_with_token
  end
end
