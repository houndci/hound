REDIS = Redis.new(url: ENV['REDISTOGO_URL'])
Resque.redis = REDIS
