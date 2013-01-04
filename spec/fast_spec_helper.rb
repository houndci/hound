$: << File.expand_path('../..', __FILE__)

Dir['spec/support/**/*.rb'].each {|f| require f}

RSpec.configure do |config|
  config.order = "random"
end
