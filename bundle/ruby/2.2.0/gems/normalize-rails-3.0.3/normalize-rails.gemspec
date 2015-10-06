# -*- encoding: utf-8 -*-
require File.expand_path('../lib/normalize-rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nicolas Gallagher", "Jonathan Neal", "Mark McConachie"]
  gem.email         = ["mark@markmcconachie.com"]
  gem.description   = %q{Normalize.css is an alternative to CSS resets}
  gem.summary       = %q{Normalize.css is a customisable CSS file that makes browsers render all elements more consistently and in line with modern standards. We researched the differences between default browser styles in order to precisely target only the styles that need normalizing.}
  gem.homepage      = "https://github.com/markmcconachie/normalize-rails"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "normalize-rails"
  gem.require_paths = ["lib"]
  gem.version       = Normalize::Rails::VERSION

  gem.add_development_dependency "rake"
end
