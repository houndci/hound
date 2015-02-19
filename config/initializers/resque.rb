require "resque-retry"
require "resque-sentry"
require "resque-timeout"
require "resque/failure/redis"
require "resque/server"

Resque.after_fork do
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end

Resque.before_fork do
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

Resque::Failure::MultipleWithRetrySuppression.classes = [
  Resque::Failure::Redis,
  Resque::Failure::Sentry,
]

Resque::Failure::Sentry.logger = "resque"

Resque::Plugins::Timeout.timeout = (ENV["RESQUE_JOB_TIMEOUT"] || 120).to_i

Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == ENV['RESQUE_ADMIN_PASSWORD']
end
