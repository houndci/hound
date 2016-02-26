module Admin
  class JobFailuresController < Admin::ApplicationController
    def index
      grouped_job_failures = JobFailure.all.group_by(&:error)

      render locals: { resources: grouped_job_failures }
    end
  end
end
