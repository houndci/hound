module ReposHelper
  def switch(repo)
    current_state = repo.enabled ? "off" : "on"
    link_to(current_state, "#", "data-github-id" => repo.github_id)
  end
end
