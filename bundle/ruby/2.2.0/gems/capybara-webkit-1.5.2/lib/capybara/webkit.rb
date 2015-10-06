require "capybara"

module Capybara
  module Webkit
  end
end

require "capybara/webkit/driver"

Capybara.register_driver :webkit do |app|
  Capybara::Webkit::Driver.new(app)
end

Capybara.register_driver :webkit_debug do |app|
  driver = Capybara::Webkit::Driver.new(app)
  driver.enable_logging
  driver
end
