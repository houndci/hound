require 'test_helper'

class ControllerLoggingTest < ActiveSupport::IntegrationCase
  test 'Log from a controller' do
    visit bar_index_path
    assert_match "Logging with Rails.logger", STDOUT.string
    assert_match "Logging with logger",       STDOUT.string
    assert_no_match(/This should not be logged!/, STDOUT.string)
  end
end
