# vim:fileencoding=utf-8

require 'resque/tasks'
require 'resque-scheduler'

namespace :resque do
  task :setup

  def scheduler_cli
    @scheduler_cli ||= Resque::Scheduler::Cli.new(
      %W(#{ENV['RESQUE_SCHEDULER_OPTIONS']})
    )
  end

  desc 'Start Resque Scheduler'
  task scheduler: :scheduler_setup do
    scheduler_cli.setup_env
    scheduler_cli.run_forever
  end

  task :scheduler_setup do
    scheduler_cli.parse_options
    Rake::Task['resque:setup'].invoke unless scheduler_cli.pre_setup
  end
end
