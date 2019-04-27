module Admin
  class JobFailuresController < Admin::ApplicationController
    def index
      render locals: { resources: JobFailure.grouped }
    end

    def destroy
      JobFailure.remove(params[:ids])

      redirect_to action: :index
    end
  end
end
