require_relative "production"

Houndapp::Application.configure do
  config.action_mailer.default_url_options = { :host => 'staging.houndci.com' }
  config.log_level = :info
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    { params: event.payload[:params].reject { |k| %w(controller action).include? k } }
  end
end
