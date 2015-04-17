# Backport of https://github.com/rails/rails/pull/18260.
#
# This allows job instances to customize their
# deserialization, which we use to implement
# job retries.

if ActiveJob::Base.method_defined?(:deserialize)
  raise "Rails 5 backport in lib/ext/active_job/base.rb no longer necessary."
end

module ActiveJob
  class Base
    def self.deserialize(job_data)
      job = job_data["job_class"].constantize.new
      job.deserialize(job_data)
      job
    end

    def deserialize(job_data)
      self.job_id = job_data["job_id"]
      self.queue_name = job_data["queue_name"]
      self.serialized_arguments = job_data["arguments"]
    end
  end
end
