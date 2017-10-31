class RepoSynchronization
  pattr_initialize :user
  attr_reader :user
  attr_accessor :owner_ids

  def start
    user.repos.clear
    user.owners.clear

    repos = api.repos

    Repo.transaction do
      process(repos)
      create_user_ownerships
    end
  end

  private

  def process(repos)
    self.owner_ids = []

    repos.each do |resource|
      attributes = resource.to_hash

      owner_ids << attributes[:owner][:id]

      owner = upsert_owner(attributes[:owner])
      repo = upsert_repo(owner, attributes)
      create_user_membership_from(repo, attributes)
    end
  end

  def create_user_membership_from(repo, attributes)
    is_admin = attributes[:permissions][:admin]
    return if user.memberships.exists?(repo: repo, admin: is_admin)

    user.memberships.create(repo: repo, admin: is_admin)
  end

  def create_user_ownerships
    Owner.where(github_id: owner_ids.uniq).find_each do |owner|
      next if user.ownerships.exists?(owner: owner)
      next unless user_is_org_owner?(owner) || repo_belongs_to_user?(owner)

      user.ownerships.create(owner: owner)
    end
  end

  def api
    @api ||= GithubApi.new(user.token)
  end

  def upsert_repo(owner, attributes)
    type = attributes[:owner][:type]

    repo_attributes = {
      private: attributes[:private],
      github_id: attributes[:id],
      name: attributes[:full_name],
      in_organization: type == GithubApi::ORGANIZATION_TYPE,
      owner: owner,
    }

    Repo.find_or_create_with(repo_attributes)
  end

  def upsert_owner(attributes)
    Owner.upsert(
      github_id: attributes[:id],
      name: attributes[:login],
      organization: attributes[:type] == GithubApi::ORGANIZATION_TYPE,
    )
  end

  def user_is_org_owner?(owner)
    return false unless owner.organization?

    membership = api.org_membership(owner.name).to_hash

    membership[:role] == GithubApi::ORG_OWNER_TYPE
  end

  def repo_belongs_to_user?(owner)
    owner.name == user.username
  end
end
