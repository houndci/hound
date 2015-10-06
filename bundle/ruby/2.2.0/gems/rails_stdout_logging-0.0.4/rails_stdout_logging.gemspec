# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rails_stdout_logging/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Dollar", "Jonathan Dance", "Richard Schneeman"]
  gem.email         = ["david@heroku.com", "jd@heroku.com", "richard@heroku.com"]
  gem.description   = %q{Sets Rails to log to stdout}
  gem.summary       = %q{Overrides Rails' built in logger to send all logs to stdout}
  gem.homepage      = "https://github.com/heroku/rails_stdout_logging"
  gem.license       = 'MIT'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rails_stdout_logging"
  gem.require_paths = ["lib"]
  gem.add_development_dependency "test-unit", "~> 3"
  gem.version       = RailsStdoutLogging::VERSION
end
