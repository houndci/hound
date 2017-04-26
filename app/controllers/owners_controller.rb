class OwnersController < ApplicationController
  def update
    if owner.update(owner_params)
      render json: owner
    end
  end

  private

  def owner
    @_owner ||= Owner.find(params[:id])
  end

  def owner_params
    params.require(:owner).permit(:config_enabled, :config_repo)
  end
end
