source "https://rubygems.org"

ruby "2.1.2"

gem "active_model_serializers"
gem "angularjs-rails"
gem "bourbon"
gem "coffee-rails"
gem "dalli"
gem "faraday-http-cache"
gem "font-awesome-rails"
gem "haml-rails"
gem "high_voltage"
gem "jquery-rails"
gem "memcachier"
gem "neat"
gem "newrelic_rpm"
gem "octokit"
gem "omniauth-github"
gem "paranoia", "~> 2.0"
gem "pg"
gem "rails", "4.0.4"
gem "resque", "~> 1.22.0"
gem "resque-retry"
gem "resque-sentry"
gem "rubocop", "0.24.1"
gem "sass-rails", "~> 4.0.2"
gem "sentry-raven"
gem "stripe"
gem "uglifier", ">= 1.0.3"
gem "unicorn"

group :staging, :production do
  gem "rails_12factor"
end

group :development, :test do
  gem "byebug"
  gem "foreman"
  gem "konacha"
  gem "poltergeist"
  gem "rspec-rails", ">= 2.14"
end

group :test do
  gem "capybara", "~> 2.1.0"
  gem "capybara-webkit", "~> 1.1.1"
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "launchy"
  gem "shoulda-matchers"
  gem "webmock"
end
