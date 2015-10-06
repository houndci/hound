# vim:fileencoding=utf-8

require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'yaml'

namespace :resque do
  task :setup do
    require 'resque'
    require 'resque-scheduler'

    rails_root = ENV['RAILS_ROOT'] || File.expand_path('../../../', __FILE__)
    rails_env = ENV['RAILS_ENV'] || 'development'

    # In resque-only servers we must require each job class individually,
    # because we're not running the full Rails app
    require "#{rails_root}/app/jobs/send_email_job"
    require "#{rails_root}/app/jobs/fix_schedules_job"

    resque_config = YAML.load_file(
      File.join(rails_root.to_s, 'config', 'resque.yml')
    )
    Resque.redis = resque_config[rails_env]

    # If you want to be able to dynamically change the schedule,
    # uncomment this line.  A dynamic schedule can be updated via the
    # Resque::Scheduler.set_schedule (and remove_schedule) methods.
    # When dynamic is set to true, the scheduler process looks for
    # schedule changes and applies them on the fly.
    # Note: This feature is only available in >=2.0.0.
    Resque::Scheduler.dynamic = true

    # Load static schedule (only in background servers).
    # The schedule doesn't need to be stored in a YAML, it just needs to
    # be a hash.  YAML is usually the easiest.
    Resque.schedule = YAML.load_file(
      File.join(rails_root.to_s, 'config', 'static_schedule.yml')
    )

    Resque.before_fork do |job|
      # Reconnect to the DB before running each job. Otherwise we get errors if
      # the DB is restarted after starting Resque.
      # Absolutely necessary on Heroku, otherwise we get a "PG::Error: SSL
      # SYSCALL error: EOF detected" exception
      ActiveRecord::Base.establish_connection
    end
  end
end
