class RepoSynchronization
  attr_reader :user, :api

  def initialize(user)
    @user = user
    @api = GithubApi.new(user.github_token)
  end

  def start
    user.repos.clear

    api.repos.each do |repo_data|
      repo = Repo.where(github_id: repo_data[:id]).first

      if repo
        user.repos << repo
      else
        user.repos.create!(
          name: repo_data[:name],
          full_github_name: repo_data[:full_name],
          github_id: repo_data[:id]
        )
      end
    end
  end
end
