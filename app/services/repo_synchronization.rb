class RepoSynchronization
  attr_reader :api, :user

  def initialize(user, github_token)
    @user = user
    @api = GithubApi.new(github_token)
  end

  def start
    user.repos.clear

    api.repos.each do |repo_data|
      user.repos << find_or_create_repo_with(repo_data)
    end
  end

  private

  def find_or_create_repo_with(repo_data)
    repo = Repo.find_or_create_by!(github_id: repo_data[:id]) do |new_repo|
      new_repo.full_github_name = repo_data[:full_name]
    end

    repo.update_changed_attributes(repo_data)
    repo
  end
end
