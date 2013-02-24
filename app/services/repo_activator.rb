class RepoActivator
  def activate(github_id, full_github_name, user, api, host)
    repo = user.github_repo(github_id)

    if repo
      repo.activate
    else
      repo = user.create_github_repo(
        github_id: github_id,
        active: true,
        full_github_name: full_github_name
      )
    end

    hook = api.create_pull_request_hook(
      full_github_name,
      callback_url(host, user.github_token)
    )

    repo.update_hook_id(hook.id)
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
