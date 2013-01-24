ENV['RAILS_ENV'] ||= 'test'

require 'fast_spec_helper'
require 'config/environment'
require 'rspec/rails'
require 'bourne'

RSpec.configure do |config|
  config.mock_with :mocha
  config.infer_base_class_for_anonymous_controllers = false
  config.include OauthHelper
  config.include SigninHelper
  WebMock.disable_net_connect!(allow_localhost: true)
  DatabaseCleaner.strategy = :deletion

  config.before do
    DatabaseCleaner.clean
  end
end

Capybara.configure do |config|
  config.javascript_driver = :webkit
end

OmniAuth.configure do |config|
  config.test_mode = true
end
