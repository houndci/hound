# frozen_string_literal: true
module Admin
  class MasqueradesController < Admin::ApplicationController
    def show
      requested_user = User.find_by(username: params[:username])
      session[:masqueraded_user_id] = requested_user.id

      redirect_to repos_path
    end

    def destroy
      session.delete(:masqueraded_user_id)

      redirect_to repos_path
    end
  end
end
