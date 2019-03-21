module Admin
  class JobFailuresController < Admin::ApplicationController
    def index
      grouped_job_failures = JobFailure.all.group_by(&:error_message)

      render locals: { resources: grouped_job_failures }
    end

    def destroy
      JobFailure.remove(params[:ids])

      redirect_to action: :index
    end
  end
end
