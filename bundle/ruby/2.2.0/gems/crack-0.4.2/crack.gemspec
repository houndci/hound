# -*- encoding: utf-8 -*-
require File.expand_path('../lib/crack/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["John Nunemaker"]
  gem.email         = ["nunemaker@gmail.com"]
  gem.description   = %q{Really simple JSON and XML parsing, ripped from Merb and Rails.}
  gem.summary       = %q{Really simple JSON and XML parsing, ripped from Merb and Rails.}
  gem.homepage      = "http://github.com/jnunemaker/crack"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "crack"
  gem.require_paths = ["lib"]
  gem.version       = Crack::VERSION
  gem.license       = "MIT"

  gem.add_dependency "safe_yaml", "~> 1.0.0"
end
