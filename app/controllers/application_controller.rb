# frozen_string_literal: true

class ApplicationController < ActionController::Base
  MARKETPLACE_LISTING_URL = "https://github.com/marketplace/hound"

  protect_from_forgery

  before_action :force_https
  before_action :capture_campaign_params
  before_action :authenticate

  helper_method :current_user, :signed_in?, :masquerading?, :account_path

  protected

  def verified_request?
    super || valid_authenticity_token?(session, request.headers["X-XSRF-TOKEN"])
  end

  private

  def force_https
    if Hound::HTTPS_ENABLED && !request.ssl? && force_https?
      redirect_to protocol: "https://", status: :moved_permanently
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
    session[:installation_id] = params[:installation_id]
    unless signed_in?
      redirect_to "/auth/github"
    end
  end

  def signed_in?
    current_user.present? && current_user.token.present?
  end

  def current_user
    @_current_user ||= find_user_or_masqerade
  end

  def analytics
    @_analytics ||= Analytics.new(current_user, session[:campaign_params])
  end

  def masquerading?
    session[:masqueraded_user_id]
  end

  def find_user_or_masqerade
    if masquerading?
      User.find_by(id: session[:masqueraded_user_id])
    else
      User.find_by(remember_token: session[:remember_token])
    end
  end

  def account_path
    if current_user&.has_marketplace_repos?
      MARKETPLACE_LISTING_URL
    else
      super
    end
  end
end
