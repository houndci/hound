module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_admin

    private

    def authenticate_admin
      unless github_admin?
        redirect_to :root
      end
    end

    def github_admin?
      current_user &&
        admin_github_handles.include?(current_user.github_username)
    end

    def current_user
      @current_user ||= User.find_by(remember_token: session[:remember_token])
    end

    def admin_github_handles
      ENV.fetch("ADMIN_GITHUB_USERNAMES", "").split(",")
    end
  end
end
