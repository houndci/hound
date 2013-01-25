class ReposController < ApplicationController
  def index
    @repos = Repo.find_all_by_user(current_user)
  end
end
