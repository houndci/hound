class RepoSynchronization
  attr_reader :user, :api

  def initialize(user)
    @user = user
    @api = GithubApi.new(user.github_token)
  end

  def start
    existing_github_ids = user.repos.map(&:github_id)

    api.get_repos.each do |repo|
      unless existing_github_ids.include?(repo[:id])
        user.repos.create(
          name: repo[:name],
          full_github_name: repo[:full_name],
          github_id: repo[:id]
        )
      end
    end
  end
end
