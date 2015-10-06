Gem::Specification.new do |gem|
  gem.name = 'resque-sentry'
  gem.version = '1.2.0'
  gem.authors = ['Harry Marr']
  gem.email = ['harry@gocardless.com']
  gem.summary = 'A failure backend for Resque that sends events to Sentry'
  gem.homepage = 'https://github.com/gocardless/resque-sentry'

  gem.add_dependency 'resque', '>= 1.18.0'
  gem.add_dependency 'sentry-raven', '>= 0.4.6'
  gem.add_development_dependency 'rspec', '~> 2.6'
  gem.add_development_dependency 'mocha', '~> 0.11.0'

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- spec/*`.split("\n")
end
