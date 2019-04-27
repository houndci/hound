module Admin
  module JobFailuresHelper
    def latest_failed_at(job_failures)
      latest_failed = job_failures.max_by(&:failed_at).failed_at

      Time.zone.at(latest_failed).strftime("%l:%M%P, %b %e")
    end
  end
end
