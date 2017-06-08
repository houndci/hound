module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_admin

    helper_method :navigation_resources

    private

    def navigation_resources
      Administrate::Namespace.new(namespace).resources.select do |resource|
        DashboardManifest::DASHBOARDS.include?(resource.name)
      end
    end

    def authenticate_admin
      unless github_admin?
        redirect_to :root
      end
    end

    def github_admin?
      current_user &&
        Hound::ADMIN_GITHUB_USERNAMES.include?(current_user.username)
    end

    def current_user
      @current_user ||= User.find_by(remember_token: session[:remember_token])
    end
  end
end
