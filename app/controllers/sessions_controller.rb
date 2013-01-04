class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_or_create_by_github_username(github_username)
    session[:current_user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session[:current_user_id] = nil
    redirect_to root_path, message: 'You have been signed out'
  end

  private

  def github_username
    env['omniauth.auth']['info']['nickname']
  end
end
