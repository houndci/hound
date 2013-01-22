module ReposHelper
  def switch(repo, active)
    current_state = active ? 'off' : 'on'
    link_to current_state, '#', 'data-id' => repo.id
  end
end
