source "https://rubygems.org"

ruby "2.2.0"

gem "active_model_serializers", "0.8.3"
gem "analytics-ruby", "~> 2.0.0", require: "segment/analytics"
gem "angularjs-rails"
gem "angular_rails_csrf"
gem "attr_extras"
gem "bourbon"
gem "coffee-rails"
gem "coffeelint"
gem "font-awesome-rails"
gem "haml-rails"
gem "high_voltage"
gem "jquery-rails"
gem "jshintrb"
gem "neat"
gem "newrelic_rpm"
gem "octokit"
gem "omniauth-github"
gem "paranoia", "~> 2.0"
gem "pg"
gem "rails", "4.2"
gem "responders", "~> 2.0"
gem "resque", "~> 1.22.0"
gem "resque-retry"
gem "resque-sentry"
gem "rubocop", "0.25.0"
gem "sass-rails"
gem "scss-lint", require: false
gem "sentry-raven"
gem "stripe"
gem "stripe_event"
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
  gem "capybara", "~> 2.4.0"
  gem "capybara-webkit"
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "launchy"
  gem "shoulda-matchers"
  gem "webmock"
end
