# frozen_string_literal: true

class ReposController < ApplicationController
  def index
    respond_to do |format|
      format.html

      format.json do
        if current_user.has_repos_with_missing_information?
          current_user.repos.clear
        end

        repos = ReposWithMembershipOrSubscriptionQuery.call(current_user)

        render json: repos
      end
    end
  end
end
