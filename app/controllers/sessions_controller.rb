class SessionsController < ApplicationController
  skip_before_filter :authenticate, only: [:new, :create]

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
    user = User.where(github_username: github_username).first_or_create
    session[:github_token] = github_token
    session[:remember_token] = user.remember_token
  end

  def destroy_session
    session[:remember_token] = nil
  end

  def github_username
    env['omniauth.auth']['info']['nickname']
  end

  def github_token
    env['omniauth.auth']['credentials']['token']
  end
end
