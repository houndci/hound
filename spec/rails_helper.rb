ENV["RAILS_ENV"] ||= "test"

require "config/environment"
require "rspec/rails"
require "sidekiq/testing"

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
  config.include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

OmniAuth.configure do |config|
  config.test_mode = true
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1280,1024")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Capybara.javascript_driver = :headless_chrome
Capybara.server = :puma, { Silent: true, Threads: "1:1" }
