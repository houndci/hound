class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:create]

  def create
    create_session

    if github_token
      update_user
      update_scopes
    end

    redirect_to setup_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def user
    @user ||= find_user || create_user
  end

  def find_user
    User.find_by(username: username).tap do |user|
      if user
        Analytics.new(user).track_signed_in
      end
    end
  end

  def create_user
    user = User.create!(
      username: username,
      email: github_email,
      utm_source: session[:campaign_params].try(:[], :utm_source),
    )
    flash[:signed_up] = true
    user
  end

  def create_session
    session[:remember_token] = user.remember_token
  end

  def github
    GitHubApi.new(github_token)
  end

  def username
    request.env["omniauth.auth"]["info"]["nickname"]
  end

  def github_email
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

  def update_user
    user.update!(token: github_token, email: github_email)
  end

  def update_scopes
    if scopes_changed?
      user.update!(token_scopes: token_scopes)
      user.repos.clear
    end
  end
end
