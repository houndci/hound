module ReposHelper
  def switch(repo)
    current_state = repo.active ? 'off' : 'on'
    link_to(current_state, '#', { 'data-github-id' => repo.github_id })
  end

  def has_active_repos?(user)
    user.repos.any? && user.has_active_repos?
  end

  def has_no_builds?(user)
    user.has_active_repos? && user.builds.none?
  end
end
