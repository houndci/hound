class RepoActivator
  def activate(repo, user)
    change_repository_state_quietly do
      github = GithubApi.new(user.github_token)
      hook = create_web_hook(github, repo)
      github.add_hound_to_repo(repo.full_github_name)
      repo.update_attributes(hook_id: hook.id, active: true)
    end
  end

  def deactivate(repo)
    change_repository_state_quietly do
      github = GithubApi.new(repo.github_token)
      github.remove_pull_request_hook(repo.full_github_name, repo.hook_id)
      repo.deactivate
    end
  end

  private

  def change_repository_state_quietly
    yield
    true
    rescue Octokit::Error => error
      capture_exception(error)
      false
  end

  def callback_url(host)
    URI.join(host, 'builds').to_s
  end

  def create_web_hook(github, repo)
    github.create_pull_request_hook(
      repo.full_github_name,
      callback_url("http://#{ENV['HOST']}")
    )
  end
end
