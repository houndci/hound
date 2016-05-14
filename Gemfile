source "https://rubygems.org"

ruby "2.3.1"

gem "active_model_serializers", "0.9.5"
gem "administrate", ">= 0.1.3"
gem "analytics-ruby", "~> 2.0.0", require: "segment/analytics"
gem "angular_rails_csrf"
gem "angularjs-rails"
gem "astrolabe"
gem "attr_extras"
gem "bourbon"
gem "coffee-rails"
gem "coffeelint"
gem "email_validator"
gem "faraday"
gem "font-awesome-rails"
gem "haml-rails"
gem "high_voltage"
gem "inifile"
gem "jquery-rails", "~> 4.0.0"
gem "neat"
gem "octokit"
gem "omniauth-github"
gem "paranoia", "~> 2.0"
gem "pg"
gem "puma"
gem "rails", "4.2.5.2"
gem "resque", "~> 1.25.0"
gem "resque-scheduler"
gem "resque-sentry"
gem "rest-client", ">= 1.8.0"
gem "rubocop"
gem "sass-rails"
gem "split", require: "split/dashboard"
gem "stripe"
gem "uglifier", ">= 2.7.2"

group :staging, :production do
  gem "rack-timeout"
  gem "rails_12factor"
  gem "sentry-raven", ">= 0.12.2"
end

group :development, :test do
  gem "byebug"
  gem "dotenv-rails"
  gem "foreman"
  gem "jasmine-rails"
  gem "poltergeist"
  gem "rspec-rails", ">= 3.4"
  gem "bundler-audit", require: false
end

group :test do
  gem "capybara", "~> 2.4.0"
  gem "capybara-webkit", "~> 1.5.1"
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "launchy"
  gem "shoulda-matchers"
  gem "webmock"
end
