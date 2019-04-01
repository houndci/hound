class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:create]

  def create
    create_session
    update_user
    ab_finished(:home)

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

  def update_user
    if github_token
      user.update!(email: github_email, token: github_token)
    else
      user.update!(email: github_email)
    end
  end

  def create_session
    session[:remember_token] = user.remember_token
    session[:signed_in_with_app] = true
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
end
