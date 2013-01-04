class ApplicationController < ActionController::Base
  before_filter :authorize

  protect_from_forgery

  private

  def authorize
    unless current_user
      redirect_to sign_in_path
    end
  end

  def current_user
    @current_user ||= User.find_by_id(session[:current_user_id])
  end
end
