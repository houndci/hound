# vim:fileencoding=utf-8

module Resque
  module Scheduler
    module Plugin
      def self.hooks(job, pattern)
        job.methods.grep(/^#{pattern}/).sort
      end

      def self.run_hooks(job, pattern, *args)
        results = hooks(job, pattern).map do |hook|
          job.send(hook, *args)
        end

        results.all? { |result| result != false }
      end

      def self.run_before_delayed_enqueue_hooks(klass, *args)
        run_hooks(klass, 'before_delayed_enqueue', *args)
      end

      def self.run_before_schedule_hooks(klass, *args)
        run_hooks(klass, 'before_schedule', *args)
      end

      def self.run_after_schedule_hooks(klass, *args)
        run_hooks(klass, 'after_schedule', *args)
      end
    end
  end
end
