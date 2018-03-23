ENV["RAILS_ENV"] ||= "test"

require "config/environment"
require "rspec/rails"

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  Analytics.backend = FakeAnalyticsRuby.new

  %i(request feature).each do |type|
    config.before :each, type: type do
      stub_request(:any, /api.github.com/).to_rack(FakeGitHub)
      FakeGitHub.comments = []
    end
  end

  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.include AnalyticsHelper
  config.include AuthenticationHelper
  config.include CommitFileHelper
  config.include Features, type: :feature
  config.include HttpsHelper
  config.include OauthHelper
  config.include FactoryGirl::Syntax::Methods
  ActiveJob::Base.queue_adapter = :resque
end

OmniAuth.configure do |config|
  config.test_mode = true
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless) },
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities,
  )
end

Capybara.javascript_driver = :headless_chrome
