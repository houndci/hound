require 'test_helper'

class ServeStaticAssets < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, RailsStdoutLogging
  end

  test "Active Record" do
    str = "#{Time.now} ActiveRecord logs to stdout"
    ActiveRecord::Base.logger.info(str)
    assert_match str, STDOUT.string
  end

  test "Action Mailer" do
    str = "#{Time.now} ActionMailer logs to stdout"
    ActionMailer::Base.logger.info(str)
    assert_match str, STDOUT.string
  end

end
