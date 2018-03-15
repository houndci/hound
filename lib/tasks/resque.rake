# frozen_string_literal: true

require "resque/tasks"
require "resque/scheduler/tasks"

task "resque:setup" => :environment

namespace :resque do
  desc "Clear stuck workers"
  task clear_workers: :environment do
    Resque.workers.each do |w|
      worker_start_time = w.processing.fetch("run_at", Time.current).to_time
      time_running = Time.current - worker_start_time
      max_time_running =
        ENV.fetch("RESQUE_WORKER_TIMEOUT_MINUTES", 10).to_i.minutes

      if time_running > max_time_running
        w.unregister_worker
      end

      Resque.workers.each { |w| w.unregister_worker unless w.working? }
    end
  end

  desc "Remove old failures"
  task remove_failures: :environment do
    all_failures = Resque::Failure.all(0, Resque::Failure.count)

    ids = all_failures.each_with_object([]).with_index do |(failure, agg), i|
      if failure["failed_at"].to_time < 2.weeks.ago
        agg << i
      end
    end

    ids.reverse.each { |i| Resque::Failure.remove(i) }
  end
end
