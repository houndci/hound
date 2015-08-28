$: << File.expand_path("../..", __FILE__)

require "active_support"
require "active_support/core_ext"
require "attr_extras"
require "byebug"
require "webmock/rspec"

Dir["spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.order = "random"
  config.include GithubApiHelper
  config.include StripeApiHelper
  WebMock.disable_net_connect!(allow_localhost: true)
end
