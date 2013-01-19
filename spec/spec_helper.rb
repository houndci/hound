ENV["RAILS_ENV"] ||= 'test'
require 'fast_spec_helper'
require 'config/environment'
require 'rspec/rails'
require 'rspec/autorun'


RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false

  config.include OauthHelper
end

Capybara.configure do |config|
  config.javascript_driver = :webkit
end

OmniAuth.configure do |config|
  config.test_mode = true
end
