class SessionsController < ApplicationController
  skip_before_filter :authorize, only: [:new, :create]

  def new
  end

  def create
    create_session
    redirect_to root_path
  end

  def destroy
    destroy_session
    redirect_to root_path
  end

  private

  def create_session
    user = User.find_or_create_by_github_username(github_username)
    session[:remember_token] = user.remember_token
  end

  def destroy_session
    session[:remember_token] = nil
  end

  def github_username
    env['omniauth.auth']['info']['nickname']
  end
end
