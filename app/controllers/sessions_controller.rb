class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:create]

  def create
    user = find_user || create_user
    create_session_for(user)
    finished("auth_button")
    redirect_to repos_path
  end

  def destroy
    destroy_session
    redirect_to root_path
  end

  private

  def find_user
    user =
      User.includes(:identities).where(identities: { username: username }).first

    Analytics.new(user).track_signed_in if user

    user
  end

  def create_user
    user = User.create!(
      email_address: email_address,
      utm_source: session[:campaign_params].try(:[], :utm_source),
    ) do |record|
      record.identities.build(username: username, provider: provider)
    end
    flash[:signed_up] = true
    user
  end

  def create_session_for(user)
    session[:remember_token] = user.remember_token
    session["#{provider}_token".to_sym] = token
  end

  def destroy_session
    session[:remember_token] = nil
  end

  def username
    request.env["omniauth.auth"]["info"]["nickname"]
  end

  def email_address
    request.env["omniauth.auth"]["info"]["email"]
  end

  def token
    request.env["omniauth.auth"]["credentials"]["token"]
  end

  def provider
    request.env["omniauth.auth"]["provider"]
  end
end
