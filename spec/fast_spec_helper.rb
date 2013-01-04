APP_ROOT = File.expand_path('../..', __FILE__)

Dir["#{APP_ROOT}/spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.order = "random"
end
