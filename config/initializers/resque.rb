require 'resque/server'
require 'resque-retry'
require 'resque-sentry'
require 'resque/failure/redis'

Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == ENV['RESQUE_ADMIN_PASSWORD']
end

Resque::Failure::Sentry.logger = 'resque'

Resque::Failure::MultipleWithRetrySuppression.classes = [
  Resque::Failure::Redis,
  Resque::Failure::Sentry
]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

Resque.before_fork do
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

Resque.after_fork do
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end
