source 'https://rubygems.org'

# Specify your gem's dependencies in rainbow.gemspec
gemspec

gem 'coveralls', require: false
gem 'mime-types', '< 2.0.0', platforms: [:ruby_18]

group :guard do
  gem 'guard'
  gem 'guard-rspec'
end

platform :rbx do
  gem 'json'
  gem 'rubysl'
end
