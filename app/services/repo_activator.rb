class RepoActivator
  def activate(repo)
    repo.activate

    hook = github_api(repo).create_pull_request_hook(
      repo.full_github_name,
      callback_url("http://#{ENV['HOST']}")
    )

    repo.update_attribute(:hook_id, hook.id)
  end

  def deactivate(repo)
    github_api(repo).remove_pull_request_hook(repo.full_github_name, repo.hook_id)
    repo.deactivate
  end

  private

  def callback_url(host)
    URI.join(host, 'builds').to_s
  end

  def github_api(repo)
    GithubApi.new(repo.github_token)
  end
end
