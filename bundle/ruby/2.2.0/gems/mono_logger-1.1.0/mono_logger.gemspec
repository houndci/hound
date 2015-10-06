# coding: utf-8
 
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mono_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "mono_logger"
  spec.version       = MonoLogger::VERSION
  spec.authors       = ["Steve Klabnik"]
  spec.email         = ["steve@steveklabnik.com"]
  spec.description   = %q{A lock-free logger compatible with Ruby 2.0. Ruby does not allow you to request a lock in a trap handler because that could deadlock, so Logger is not sufficient.}
  spec.summary       = %q{A lock-free logger compatible with Ruby 2.0.}
  spec.homepage      = "http://github.com/steveklabnik/mono_logger"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 4.0"
end
