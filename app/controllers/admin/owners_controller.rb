module Admin
  class OwnersController < Admin::ApplicationController
    before_action :default_params

    private

    def default_params
      params[:order] ||= :whitelisted
      params[:direction] ||= :desc
    end
  end
end
