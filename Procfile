web: bundle exec puma -C config/puma.rb
resque_all: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=8 QUEUE=high,medium,low bundle exec rake resque:work
resque_high: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=8 QUEUE=high,medium bundle exec rake resque:work
resque_medium: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=8 QUEUE=medium bundle exec rake resque:work
resque_low: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=8 QUEUE=low,medium bundle exec rake resque:work
resque_scheduler: bundle exec rake resque:scheduler
