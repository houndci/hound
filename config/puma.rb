workers Integer(ENV.fetch("WEB_CONCURRENCY", 3))
threads_count = Integer(ENV.fetch("MAX_THREADS", 5))
threads(threads_count, threads_count)

preload_app!

port ENV.fetch("PORT", 3000)
environment ENV.fetch("RACK_ENV", "development")

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection

  # Reconnect resque's redis after worker boots
  Resque.redis = ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379")
end
