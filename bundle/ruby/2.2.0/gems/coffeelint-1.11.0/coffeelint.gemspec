# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coffeelint/version'

Gem::Specification.new do |gem|
  gem.name          = "coffeelint"
  gem.version       = Coffeelint::VERSION
  gem.authors       = ["Zachary Bush"]
  gem.email         = ["zach@zmbush.com"]
  gem.description   = %q{Ruby bindings for coffeelint}
  gem.summary       = %q{Ruby bindings for coffeelint along with railtie to add rake task to rails}
  gem.homepage      = "https://github.com/zipcodeman/coffeelint-ruby"
  gem.licenses      = ["MIT"]

  gem.files         = `git ls-files`.split($/) + %w(coffeelint/lib/coffeelint.js) - %w(bin/coffeelint)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "coffee-script"
  gem.add_dependency "json"
  gem.add_dependency "execjs"

  gem.add_development_dependency 'rspec', '~> 3.1.0'
  gem.add_development_dependency 'rake'
end
