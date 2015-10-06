require 'rake'
require 'raven'
require 'raven/cli'

namespace :raven do
  desc "Send a test event to the remote Sentry server"
  task :test, [:dsn] do |_t, args|
    Rake::Task["environment"].invoke if defined? Rails

    Raven::CLI.test(args.dsn)
  end
end
