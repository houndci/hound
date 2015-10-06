require 'helper'

class TestRails12factor < Minitest::Test
  def test_gem_dependencies_are_loaded
    assert !defined?(RailsServeStaticAssets)
    assert !defined?(RailsStdoutLogging)
    require 'rails_12factor'
    assert defined?(RailsServeStaticAssets)
    assert defined?(RailsStdoutLogging)
  end
end
