class RepoSynchronization
  pattr_initialize :user
  attr_reader :user

  def start
    user.repos.clear
    repos = api.repos

    Repo.transaction do
      repos.each do |resource|
        begin
          create_user_membership_from!(resource)
        rescue ActiveRecord::RecordNotUnique
          next
        end
      end
    end
  end

  private

  def create_user_membership_from!(resource)
    attributes = repo_attributes(resource.to_hash)
    repo = Repo.find_or_create_with(attributes)
    user.memberships.create!(
      repo: repo,
      admin: resource.to_hash[:permissions][:admin],
    )
  end

  def api
    @api ||= GitHubApi.new(user.token)
  end

  def repo_attributes(attributes)
    owner = upsert_owner(attributes[:owner])

    {
      private: attributes[:private],
      github_id: attributes[:id],
      name: attributes[:full_name],
      in_organization: attributes[:owner][:type] == GitHubApi::ORGANIZATION_TYPE,
      owner: owner,
    }
  end

  def upsert_owner(owner_attributes)
    Owner.upsert(
      github_id: owner_attributes[:id],
      name: owner_attributes[:login],
      organization: owner_attributes[:type] == GitHubApi::ORGANIZATION_TYPE
    )
  end
end
