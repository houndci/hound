class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :force_https
  before_filter :authenticate
  after_filter  :set_csrf_cookie_for_ng
  helper_method :current_user, :signed_in?

  private

  def force_https
    if ENV['ENABLE_HTTPS'] == 'yes'
      if !request.ssl? && force_https?
        protocol = 'https'
        redirect_to protocol: "#{protocol}://", status: :moved_permanently
      end
    end
  end

  def force_https?
    true
  end

  def authenticate
    unless signed_in?
      redirect_to sign_in_path
    end
  end

  def signed_in?
    current_user.present?
  end

  def current_user
    @current_user ||= User.where(remember_token: session[:remember_token]).first
  end

  def set_csrf_cookie_for_ng
    if protect_against_forgery?
      cookies['XSRF-TOKEN'] = form_authenticity_token
    end
  end

  protected

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end
end
