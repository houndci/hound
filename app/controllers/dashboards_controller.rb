class DashboardsController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.json do
        render json: RubyViolations.new(current_user.repos.active).count
      end
    end
  end
end
