class CreateRepo
  pattr_initialize :repo
  static_facade :call, :repo

  def call
    Repo.find_or_initialize_by(github_id: repo[:id]).tap do |repo|
      repo.update!(attributes)
    end
  end

  def attributes
    {
      installation_id: repo[:installation_id],
      name: repo[:full_name],
      owner: owner,
      private: repo[:private],
    }.compact
  end

  def owner
    Owner.upsert(
      github_id: repo[:owner][:id],
      name: repo[:owner][:login],
      organization: repo[:owner][:type] == GitHubApi::ORGANIZATION_TYPE,
    )
  end
end
