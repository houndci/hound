class SessionsController < ApplicationController
  skip_before_filter :authorize, :only => [:new, :create]

  def new
  end

  def create
    user = User.find_or_create_by_github_username(github_username)
    session[:remember_token] = user.id
    redirect_to root_path
  end

  def destroy
    session[:remember_token] = nil
    redirect_to root_path, message: 'You have been signed out'
  end

  private

  def github_username
    env['omniauth.auth']['info']['nickname']
  end
end
