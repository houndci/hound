class UpdateRepoOwner
  def self.run
    Repo.where(owner_id: nil).find_each do |repo|
      response = fetch_repo(repo)

      if response.present?
        owner_github_id = response["owner"]["id"]
        owner_github_name = response["owner"]["login"]

        owner = Owner.upsert(
          github_id: owner_github_id,
          github_name: owner_github_name
        )

        puts "Updating repo: #{repo.id}"
        repo.update(owner_id: owner.id)
      end
    end
  end

  def self.fetch_repo(repo)
    begin
      GithubApi.new.repo(repo.name)
    rescue Octokit::NotFound
      puts "Could not find #{repo.name}"
      nil
    end
  end
end
