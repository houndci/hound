Split.configure do |config|
  config.experiments = YAML.load_file "config/experiments.yml"
end

Split.redis = ENV.fetch("REDIS_URL")

Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == "admin" && password == ENV.fetch("SPLIT_ADMIN_PASSWORD")
end
