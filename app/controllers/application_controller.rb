class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate
  helper_method :current_user, :signed_in?

  private

  def authenticate
    unless signed_in?
      # redirect_to sign_in_path
    end
  end

  def signed_in?
    current_user.present?
  end

  def current_user
    # @current_user ||= User.where(remember_token: session[:remember_token]).first
    @current_user = User.last
  end
end
