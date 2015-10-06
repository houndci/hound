require 'mocha'
require 'resque'
require 'resque-sentry'

RSpec.configure do |config|
  config.mock_with :mocha
end

