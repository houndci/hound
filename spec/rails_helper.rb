ENV["RAILS_ENV"] ||= "test"

require "config/environment"
require "rspec/rails"

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  Analytics.backend = FakeAnalyticsRuby.new

  config.before do
    stub_request(:any, /api.github.com/).to_rack(FakeGithub)
  end

  config.before :each, type: :request do
    FakeGithub.comments = []
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

Capybara.configure do |config|
  config.javascript_driver = :webkit
  config.default_max_wait_time = 4
end

Capybara::Webkit.configure(&:block_unknown_urls)

OmniAuth.configure do |config|
  config.test_mode = true
end
