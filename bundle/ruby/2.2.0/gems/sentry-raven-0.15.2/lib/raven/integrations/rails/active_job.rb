module Raven
  class Rails
    module ActiveJob
      def self.included(base)
        base.class_eval do
          rescue_from(Exception) do |exception|
            # Do not capture exceptions when using Sidekiq so we don't capture
            # The same exception twice.
            unless self.class.queue_adapter.to_s == 'ActiveJob::QueueAdapters::SidekiqAdapter'
              active_job_details = {
                :active_job => self.class.name,
                :arguments => arguments,
                :scheduled_at => scheduled_at,
                :job_id => job_id,
                :locale => locale,
              }

              # Add provider_job_id details if Rails 5
              if defined?(provider_job_id)
                active_job_details.merge!(:provider_job_id => provider_job_id)
              end

              Raven.capture_exception(exception, :extra => active_job_details)
              raise exception
            end
          end
        end
      end
    end
  end
end
