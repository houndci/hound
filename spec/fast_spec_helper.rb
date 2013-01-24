$: << File.expand_path('../..', __FILE__)

require 'webmock/rspec'
require 'bourne'

Dir['spec/support/**/*.rb'].each {|f| require f}

RSpec.configure do |config|
  config.order = 'random'
  config.mock_with :mocha
  config.include GithubApiHelper
end
