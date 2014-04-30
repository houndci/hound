class RepoSynchronization
  attr_reader :api, :user

  ORGANIZATION_TYPE = 'Organization'

  def initialize(user, github_token)
    @user = user
    @api = GithubApi.new(github_token)
  end

  def start
    user.repos.clear

    api.repos.each do |resource|
      attributes = repo_attributes(resource.to_hash)
      user.repos << Repo.find_or_create_with(attributes)
    end
  end

  private

  def repo_attributes(attributes)
    attributes.slice(:private).merge(
      github_id: attributes[:id],
      full_github_name: attributes[:full_name],
      in_organization: attributes[:owner][:type] == ORGANIZATION_TYPE
    )
  end
end
