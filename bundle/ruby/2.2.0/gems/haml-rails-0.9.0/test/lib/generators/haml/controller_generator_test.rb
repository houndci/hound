require 'test_helper'
require 'lib/generators/haml/testing_helper'

class Haml::Generators::ControllerGeneratorTest < Rails::Generators::TestCase
  destination Rails.root
  tests Rails::Generators::ControllerGenerator

  setup :prepare_destination
  setup :copy_routes

  arguments %w(Account foo bar --template-engine haml)

  test "should invoke haml engine" do
    run_generator 
    assert_file "app/views/account/foo.html.haml"
    assert_file "app/views/account/bar.html.haml"
  end 
end
