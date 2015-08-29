Raven.configure do |config|
  config.environments = %w{production staging}
  config.logger = Rails.logger
end
