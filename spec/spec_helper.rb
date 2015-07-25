$: << File.expand_path("../..", __FILE__)

require "attr_extras"
require "byebug"
require "webmock/rspec"
require "active_support"
require "active_support/core_ext"

Dir["spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.order = "random"
  config.include GithubApiHelper
  config.include StripeApiHelper
  WebMock.disable_net_connect!(allow_localhost: true)
end
