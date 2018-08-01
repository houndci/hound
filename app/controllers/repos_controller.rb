class ReposController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        repos = ReposWithMembershipOrSubscriptionQuery.call(current_user)

        render json: repos
      end
    end
  end
end
