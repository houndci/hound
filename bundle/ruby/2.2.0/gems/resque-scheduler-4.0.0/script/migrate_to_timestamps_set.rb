# vim:fileencoding=utf-8

require 'redis'
require 'resque'

if ARGV.size != 1
  puts 'migrate_to_timestamps_set.rb <redis-host:redis-port>'
  exit
end

Resque.redis = ARGV[0]
redis = Resque.redis
Array(redis.keys('delayed:*')).each do |key|
  jobs = redis.lrange(key, 0, -1)
  jobs.each { |job| redis.sadd("timestamps:#{job}", key) }
end
