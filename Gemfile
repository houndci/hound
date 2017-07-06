source "https://rubygems.org"

ruby "2.3.1"

gem "active_model_serializers", "0.9.5"
gem "administrate", "0.7.0"
gem "analytics-ruby", "~> 2.2.2", require: "segment/analytics"
gem "attr_extras"
gem "autoprefixer-rails"
gem "bourbon", ">= 5.0.0.beta.8"
gem "coffee-rails"
gem "email_validator"
gem "faraday"
gem "haml-rails"
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
gem "rails", "5.0.0.1"
gem "rails-assets-classnames", source: "https://rails-assets.org"
gem "rails-assets-es5-shim", source: "https://rails-assets.org"
gem "rails-assets-lodash", source: "https://rails-assets.org"
gem "rails-assets-normalize-css", source: "https://rails-assets.org"
gem "react-rails"
gem "record_tag_helper"
gem "resque", ">= 1.25.0"
gem "resque-scheduler"
gem "resque-sentry"
gem "rest-client", ">= 1.8.0"
gem "sass-rails"
gem "sinatra", "2.0.0"
gem "stripe"
gem "thor", "0.19.1"
gem "uglifier", ">= 2.7.2"

group :staging, :production do
  gem "rack-timeout"
  gem "rails_12factor"
  gem "sentry-raven", ">= 0.12.2"
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
  gem "capybara-webkit", "~> 1.6"
  gem "database_cleaner"
  gem "factory_girl_rails"
  gem "launchy"
  gem "shoulda-matchers"
  gem "webmock"
end
