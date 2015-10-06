# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rails_serve_static_assets/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Pedro Belo", "Jonathan Dance"]
  gem.email         = ["pedro@heroku.com", "jd@heroku.com"]
  gem.description   = %q{Force Rails to serve static assets}
  gem.summary       = %q{Sets serve_static_assets to true so Rails will sere your static assets}
  gem.homepage      = "https://github.com/heroku/rails_serve_static_assets"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rails_serve_static_assets"
  gem.require_paths = ["lib"]
  gem.version       = RailsServeStaticAssets::VERSION
  gem.license       = 'MIT'

  gem.add_development_dependency "rails",     [">= 3.1"]
  gem.add_development_dependency "capybara",  [">= 0"]
  gem.add_development_dependency "sprockets", [">= 0"]
end
