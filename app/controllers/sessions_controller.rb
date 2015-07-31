class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:create]

  def create
    create_session

    if github_token
      update_token
      update_scopes
    end

    finished("auth_button")
    redirect_to repos_path
  end

  def destroy
    destroy_session
    redirect_to root_path
  end

  private

  def user
    @user ||= find_user || create_user
  end

  def find_user
    if user = User.where(github_username: github_username).first
      Analytics.new(user).track_signed_in
    end

    user
  end

  def create_user
    user = User.create!(
      github_username: github_username,
      email_address: github_email_address,
      utm_source: session[:campaign_params].try(:[], :utm_source),
    )
    flash[:signed_up] = true
    user
  end

  def create_session
    session[:remember_token] = user.remember_token
  end

  def destroy_session
    session[:remember_token] = nil
  end

  def github
    GithubApi.new(github_token)
  end

  def github_username
    request.env["omniauth.auth"]["info"]["nickname"]
  end

  def github_email_address
    request.env["omniauth.auth"]["info"]["email"]
  end

  def github_token
    request.env["omniauth.auth"]["credentials"]["token"]
  end

  def scopes_changed?
    user.token_scopes != token_scopes
  end

  def token_scopes
    @token_scopes ||= github.scopes
  end

  def update_token
    user.update!(token: github_token)
  end

  def update_scopes
    if scopes_changed?
      user.update!(token_scopes: token_scopes)
      user.repos.clear
    end
  end
end
