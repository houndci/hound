class SetupsController < ApplicationController
  prepend_before_action :save_installation_id

  def show
    if session[:installation_id]
      ids = current_user.installation_ids | [session[:installation_id].to_i]
      current_user.update!(installation_ids: ids, repos: [])
    end

    redirect_to repos_path
  end

  private

  def save_installation_id
    if params[:installation_id]
      session[:installation_id] = params[:installation_id]
    end
  end
end
