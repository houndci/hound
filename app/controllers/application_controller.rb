class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :force_https
  before_action :capture_campaign_params
  before_action :authenticate
  after_action  :set_csrf_cookie_for_ng
  helper_method :current_user, :signed_in?

  private

  def force_https
    if ENV['ENABLE_HTTPS'] == 'yes'
      if !request.ssl? && force_https?
        redirect_to protocol: "https://", status: :moved_permanently
      end
    end
  end

  def force_https?
    true
  end

  def capture_campaign_params
    session[:campaign_params] ||= {
      utm_campaign: params[:utm_campaign],
      utm_medium: params[:utm_medium],
      utm_source: params[:utm_source],
    }
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

  def analytics
    @analytics ||= Analytics.new(current_user, session[:campaign_params])
  end

  def set_csrf_cookie_for_ng
    if protect_against_forgery?
      cookies['XSRF-TOKEN'] = form_authenticity_token
    end
  end

  def report_exception(exception, metadata)
    Raven.capture_exception(exception, extra: metadata)
  end

  protected

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end
end
