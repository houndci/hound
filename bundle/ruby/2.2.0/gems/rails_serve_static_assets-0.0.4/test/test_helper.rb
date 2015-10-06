ENV["RAILS_ENV"] = "test"

require 'rails'

require File.expand_path("../rails_app/config/environment.rb",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

Rails.backtrace_cleaner.remove_silencers!



# Define a bare test case to use with Capybara
class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  # include Sprockets::Rails::Helper
  # config = Rails.application.config
  # self.debug_assets  = config.assets.debug
  # self.digest_assets = config.assets.digest
  # self.assets_prefix = config.assets.prefix

  def rails_test_path(name = "")
    Pathname.new(File.expand_path("../..", __FILE__)).join("test/rails_app").join(name)
  end
end


class ActiveSupport::IntegrationCase
  def assert_has_content?(content)
    assert has_content?(content), "Expected #{page.body} to include #{content.inspect}"
  end

  def refute_has_content?(content)
    assert !has_content?(content), "Expected #{page.body} to NEVER include #{content.inspect} but was found"
  end

  def assert_success
    refute_has_content?("The page you were looking for doesn't exist.")
  end
end
