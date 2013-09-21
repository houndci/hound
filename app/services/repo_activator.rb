class RepoActivator
  def activate(repo, api)
    repo.activate

    hook = api.create_pull_request_hook(
      repo.full_github_name,
      callback_url("http://#{ENV['HOST']}", repo.user.github_token)
    )

    repo.update_attribute(:hook_id, hook.id)
  end

  def deactivate(github_api, repo)
    github_api.remove_pull_request_hook(repo.full_github_name, repo.hook_id)
    repo.deactivate
  end

  private

  def callback_url(host, token)
    URI.join(host, "builds?token=#{token}").to_s
  end
end
