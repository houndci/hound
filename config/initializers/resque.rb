require "ext/active_job/base"
require "resque-sentry"
require "resque/failure/redis"
require "resque/failure/multiple"
require "resque/server"
require "resque/scheduler/server"

Resque.after_fork do
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end

Resque.before_fork do
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

Resque::Failure::Multiple.classes = [
  Resque::Failure::Redis,
  Resque::Failure::Sentry,
]

Resque::Failure.backend = Resque::Failure::Multiple

Resque::Failure::Sentry.logger = "resque"

Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == ENV['RESQUE_ADMIN_PASSWORD']
end

ApplicationJob.timeout = ENV.fetch("RESQUE_JOB_TIMEOUT", 120).to_i
Retryable.retry_delay = ENV.fetch("RESQUE_RETRY_DELAY", 30).to_i
Retryable.retry_attempts = ENV.fetch("RESQUE_RETRY_ATTEMPTS", 10).to_i
