class RepoSynchronization
  attr_reader :api, :user

  def initialize(user, github_token)
    @user = user
    @api = GithubApi.new(github_token)
  end

  def start
    user.repos.clear

    api.repos.each do |attributes|
      user.repos << Repo.find_or_create_with(repo_attributes(attributes))
    end
  end

  private

  def repo_attributes(attributes)
    attributes.slice(:private).merge(
      github_id: attributes[:id],
      full_github_name: attributes[:full_name],
      in_organization: attributes[:organization].present?
    )
  end
end
