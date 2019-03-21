web: bundle exec puma -C config/puma.rb
webpack_dev_server: ./bin/webpack-dev-server
jobs_high: bundle exec sidekiq -q high
jobs_medium: bundle exec sidekiq -q medium -q high
jobs_low: bundle exec sidekiq -q low -q high -q medium
release: bundle exec rake db:migrate
