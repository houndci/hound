ENV['RAILS_ENV'] ||= 'test'

require 'fast_spec_helper'
require 'config/environment'
require 'rspec/rails'

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.include AuthenticationHelper
  config.include Features, type: :feature
  config.include HttpsHelper
  config.include OauthHelper
  config.include FactoryGirl::Syntax::Methods
  DatabaseCleaner.strategy = :deletion
  Delayed::Worker.delay_jobs = false

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
