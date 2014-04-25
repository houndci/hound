web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
redis: bundle exec redis-server
resque: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=8 bundle exec rake resque:work
