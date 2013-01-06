class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorize
  helper_method :signed_in?

  private

  def authorize
    unless signed_in?
      redirect_to sign_in_path
    end
  end

  def signed_in?
    current_user.present?
  end

  def current_user
    @current_user ||= User.where(remember_token: session[:remember_token])
  end
end
