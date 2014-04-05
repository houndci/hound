class RepoActivator
  def activate(repo, github_token)
    change_repository_state_quietly do
      github = GithubApi.new(github_token)
      add_hound_to_repo(github, repo)
      create_web_hook(github, repo)
    end
  end

  def deactivate(repo, github_token)
    change_repository_state_quietly do
      github = GithubApi.new(github_token)
      github.remove_hook(repo.full_github_name, repo.hook_id)
      repo.deactivate
    end
  end

  private

  def change_repository_state_quietly
    yield
    true
  rescue Octokit::Error => error
    Raven.capture_exception(error)
    false
  end

  def create_web_hook(github, repo)
    github.create_hook(repo.full_github_name, builds_url) do |hook|
      repo.update_attributes(hook_id: hook.id, active: true)
    end
  end

  def add_hound_to_repo(github, repo)
    github.add_user_to_repo(
      ENV['HOUND_GITHUB_USERNAME'],
      repo.full_github_name
    )
  end

  def builds_url
    protocol = ENV['ENABLE_HTTPS'] == 'yes' ? 'https' : 'http'
    URI.join("#{protocol}://#{ENV['HOST']}", 'builds').to_s
  end
end
