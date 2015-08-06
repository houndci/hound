class RepoSynchronization
  pattr_initialize :user
  attr_reader :user

  def start
    user.repos.clear
    repos = api.repos

    Repo.transaction do
      repos.each do |resource|
        attributes = repo_attributes(resource.to_hash)
        user.repos << Repo.find_or_create_with(attributes)
      end
    end
  end

  private

  def api
    @api ||= GithubApi.new(user.token)
  end

  def repo_attributes(attributes)
    owner = upsert_owner(attributes[:owner])

    {
      private: attributes[:private],
      github_id: attributes[:id],
      full_github_name: attributes[:full_name],
      in_organization: attributes[:owner][:type] == GithubApi::ORGANIZATION_TYPE,
      owner: owner,
    }
  end

  def upsert_owner(owner_attributes)
    Owner.upsert(
      github_id: owner_attributes[:id],
      name: owner_attributes[:login],
      organization: owner_attributes[:type] == GithubApi::ORGANIZATION_TYPE
    )
  end
end
