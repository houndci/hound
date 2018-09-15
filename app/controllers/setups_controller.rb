class SetupsController < ApplicationController
  def show
    if session[:installation_id]
      ids = current_user.installation_ids | [session[:installation_id].to_i]
      current_user.update(installation_ids: ids, repos: [])
    end

    redirect_to repos_path
  end
end
