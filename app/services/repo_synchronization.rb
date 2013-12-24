class RepoSynchronization
  attr_reader :user, :api

  def initialize(user)
    @user = user
    @api = GithubApi.new(user.github_token)
  end

  def start
    api.repos.each do |repo_data|
      repo = Repo.find_by(github_id: repo_data[:id])

      if repo
        unless user.repos.include? repo
          user.repos << repo
        end
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
