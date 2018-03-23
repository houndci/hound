source "https://rubygems.org"

ruby "2.5.0"

gem "active_model_serializers", "0.9.5"
gem "administrate", "0.8.1"
gem "analytics-ruby", "~> 2.2.2", require: "segment/analytics"
gem "attr_extras"
gem "autoprefixer-rails"
gem "bourbon", "~> 5.0"
gem "coffee-rails"
gem "email_validator"
gem "faraday"
gem "haml-rails", "~> 1.0"
gem "high_voltage"
gem "inifile"
gem "jquery-rails", ">= 4.2.0"
gem "neat", "~> 1.9"
gem "octokit"
gem "omniauth-github"
gem "paranoia", "~> 2.2"
gem "pathspec"
gem "pg"
gem "puma"
gem "rails", "~> 5.1.4"
gem "rails-assets-normalize-css", source: "https://rails-assets.org"
gem "record_tag_helper"
gem "resque", ">= 1.27.4"
gem "resque-scheduler"
gem "resque-sentry"
gem "resque-rollbar"
gem "rest-client", ">= 1.8.0"
gem "rollbar"
gem "sass-rails"
gem "sinatra", "~> 2.0"
gem "stripe"
gem "thor", "0.19.1"
gem "uglifier", ">= 2.7.2"
gem "webpacker", "~> 3.0"
gem "webpacker-react", "~> 0.3.1"
gem "nokogiri", ">= 1.8.2"

group :staging, :production do
  gem "lograge", ">= 0.7.1"
  gem "rack-timeout"
end

group :development, :test do
  gem "bundler-audit", require: false
  gem "byebug"
  gem "dotenv-rails"
  gem "foreman"
  gem "rspec-rails", ">= 3.4"
end

group :test do
  gem "capybara", ">= 2.4.0"
  gem "selenium-webdriver"
  gem "factory_girl_rails"
  gem "launchy"
  gem "shoulda-matchers"
  gem "webmock"
end
