class UsersController < ApplicationController
  respond_to :json

  def show
    respond_with current_user
  end
end
