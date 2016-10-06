require_relative "production"

Houndapp::Application.configure do
  config.action_mailer.default_url_options = { :host => 'staging.houndci.com' }
  config.log_level = :info
end

