module Admin
  class JobFailuresController < Admin::ApplicationController
    def index
      grouped_job_failures = JobFailure.all.group_by(&:error).
        sort_by { |error, failures| failures.map(&:index).size }.
        reverse

      render locals: { resources: grouped_job_failures }
    end

    def destroy
      job_failure_indexes = params[:id].split(",")
      JobFailure.remove(job_failure_indexes)

      redirect_to action: :index
    end
  end
end
