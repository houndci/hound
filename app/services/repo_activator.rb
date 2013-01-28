class RepoActivator
  def activate(github_id, full_github_name, user, api, host)
    repo = user.github_repo(github_id)

    if repo
      repo.activate
    else
      user.create_github_repo(github_id: github_id, active: true)
    end

    api.create_pull_request_hook(full_github_name, URI.join(host, 'builds').to_s)
  end
end
