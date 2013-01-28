class RepoActivator
  def activate(github_id, full_github_name, relation, api, host)
    repo = relation.where(github_id: github_id).first

    if repo
      repo.activate
    else
      relation.create(github_id: github_id, active: true)
    end

    api.create_pull_request_hook(full_github_name, URI.join(host, 'builds').to_s)
  end
end
