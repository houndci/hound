require 'rspec/its'

begin
  require 'coveralls'
  Coveralls.wear!
rescue LoadError
  warn "warning: coveralls gem not found; skipping Coveralls"
end

RSpec.configure do |config|
  config.warnings = true
end
