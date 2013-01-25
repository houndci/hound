class ReposController < ApplicationController
  def index
    @repos = Repo.all_by_user(current_user)
  end
end
