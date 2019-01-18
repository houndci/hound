require "sidekiq"
require "redis-namespace"

Sidekiq.configure_client do |config|
  config.redis = { namespace: "resque" }
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: "resque" }
end
