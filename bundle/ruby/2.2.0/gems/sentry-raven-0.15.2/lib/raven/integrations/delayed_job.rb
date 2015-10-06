require 'delayed_job'

module Delayed
  module Plugins

    class Raven < ::Delayed::Plugin
      callbacks do |lifecycle|
        lifecycle.around(:invoke_job) do |job, *args, &block|
          begin
            # Forward the call to the next callback in the callback chain
            block.call(job, *args)

          rescue Exception => exception
            # Log error to Sentry
            ::Raven.capture_exception(exception,
              :logger  => 'delayed_job',
              :tags    => {
                 :delayed_job_queue => job.queue,
                 :delayed_job_id => job.id
              },
              :extra => {
                  :delayed_job => {
                      :id          => job.id,
                      :priority    => job.priority,
                      :attempts    => job.attempts,
                      :handler     => job.handler,
                      :last_error  => job.last_error,
                      :run_at      => job.run_at,
                      :locked_at   => job.locked_at,
                      #failed_at  => job.failed_at,
                      :locked_by   => job.locked_by,
                      :queue       => job.queue,
                      :created_at  => job.created_at
                  }
              })

            # Make sure we propagate the failure!
            raise exception
          end
        end
      end
    end

  end
end

##
# Register DelayedJob Raven plugin
#
Delayed::Worker.plugins << Delayed::Plugins::Raven
