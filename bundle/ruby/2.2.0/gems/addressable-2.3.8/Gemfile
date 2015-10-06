source 'https://rubygems.org'

gemspec

group :development do
  gem 'yard'
  gem 'redcarpet', :platform => :mri_19
  gem 'rubyforge'
end

group :test, :development do
  gem 'coveralls', :require => false, :platforms => [
    :ruby_19, :ruby_20, :ruby_21, :rbx, :jruby
  ]
end

gem 'idn', :platform => :mri_18
gem 'idn-ruby', :platform => :mri_19

platforms :ruby_18 do
  gem 'mime-types', '~> 1.25'
  gem 'rest-client', '~> 1.6.8'
end

platforms :rbx do
  gem 'rubysl-openssl', '2.2.1'
end
