class RepoActivator
  def activate(repo)
    repo.activate

    hook = github_api(repo).create_pull_request_hook(
      repo.full_github_name,
      callback_url("http://#{ENV['HOST']}", repo.user.github_token)
    )

    repo.update_attribute(:hook_id, hook.id)
  end

  def deactivate(repo)
    github_api(repo).remove_pull_request_hook(repo.full_github_name, repo.hook_id)
    repo.deactivate
  end

  private

  def callback_url(host, token)
    URI.join(host, "builds?token=#{token}").to_s
  end

  def github_api(repo)
    GithubApi.new(repo.user.github_token)
  end
end
