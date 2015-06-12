class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:create]

  def create
    if ensure_org
      user = find_user || create_user
      create_session_for(user)
      finished("auth_button")
      redirect_to repos_path
    else
      redirect_to root_path
    end
  end

  def destroy
    destroy_session
    redirect_to root_path
  end

  private

  def find_user
    if user = User.where(github_username: github_username).first
      Analytics.new(user).track_signed_in
    end

    user
  end

  def create_user
    user = User.create!(
      github_username: github_username,
      email_address: github_email_address
    )
    flash[:signed_up] = true
    user
  end

  def ensure_org
    return true unless ENV['LIMIT_ACCESS_TO_ORG']

    client = GithubApi.new(github_token)
    org_names = client.orgs.map { |org_hash| org_hash[:login] }
    org_names.include?(ENV['LIMIT_ACCESS_TO_ORG'])
  end

  def create_session_for(user)
    session[:remember_token] = user.remember_token
    session[:github_token] = github_token
  end

  def destroy_session
    session[:remember_token] = nil
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
end
