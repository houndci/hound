class NullRepo
  attr_reader :user, :github_id

  def initialize(attributes)
    @user = attributes[:user]
    @github_id = attributes[:github_id]
  end

  def id
    nil
  end

  def activate
    user.repos.create(github_id: github_id, active: true)
  end
end
