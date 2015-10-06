require 'redis'
require 'redis/namespace/version'

class Redis
  class Namespace
    # The following table defines how input parameters and result
    # values should be modified for the namespace.
    #
    # COMMANDS is a hash. Each key is the name of a command and each
    # value is a two element array.
    #
    # The first element in the value array describes how to modify the
    # arguments passed. It can be one of:
    #
    #   nil
    #     Do nothing.
    #   :first
    #     Add the namespace to the first argument passed, e.g.
    #       GET key => GET namespace:key
    #   :all
    #     Add the namespace to all arguments passed, e.g.
    #       MGET key1 key2 => MGET namespace:key1 namespace:key2
    #   :exclude_first
    #     Add the namespace to all arguments but the first, e.g.
    #   :exclude_last
    #     Add the namespace to all arguments but the last, e.g.
    #       BLPOP key1 key2 timeout =>
    #       BLPOP namespace:key1 namespace:key2 timeout
    #   :exclude_options
    #     Add the namespace to all arguments, except the last argument,
    #     if the last argument is a hash of options.
    #       ZUNIONSTORE key1 2 key2 key3 WEIGHTS 2 1 =>
    #       ZUNIONSTORE namespace:key1 2 namespace:key2 namespace:key3 WEIGHTS 2 1
    #   :alternate
    #     Add the namespace to every other argument, e.g.
    #       MSET key1 value1 key2 value2 =>
    #       MSET namespace:key1 value1 namespace:key2 value2
    #   :sort
    #     Add namespace to first argument if it is non-nil
    #     Add namespace to second arg's :by and :store if second arg is a Hash
    #     Add namespace to each element in second arg's :get if second arg is
    #       a Hash; forces second arg's :get to be an Array if present.
    #   :eval_style
    #     Add namespace to each element in keys argument (via options hash or multi-args)
    #   :scan_style
    #     Add namespace to :match option, or supplies "#{namespace}:*" if not present.
    #
    # The second element in the value array describes how to modify
    # the return value of the Redis call. It can be one of:
    #
    #   nil
    #     Do nothing.
    #   :all
    #     Add the namespace to all elements returned, e.g.
    #       key1 key2 => namespace:key1 namespace:key2
    COMMANDS = {
      "append"           => [:first],
      "auth"             => [],
      "bgrewriteaof"     => [],
      "bgsave"           => [],
      "bitcount"         => [ :first ],
      "bitop"            => [ :exclude_first ],
      "blpop"            => [ :exclude_last, :first ],
      "brpop"            => [ :exclude_last, :first ],
      "brpoplpush"       => [ :exclude_last ],
      "config"           => [],
      "dbsize"           => [],
      "debug"            => [ :exclude_first ],
      "decr"             => [ :first ],
      "decrby"           => [ :first ],
      "del"              => [ :all   ],
      "discard"          => [],
      "disconnect!"      => [],
      "dump"             => [ :first ],
      "echo"             => [],
      "exists"           => [ :first ],
      "expire"           => [ :first ],
      "expireat"         => [ :first ],
      "eval"             => [ :eval_style ],
      "evalsha"          => [ :eval_style ],
      "exec"             => [],
      "flushall"         => [],
      "flushdb"          => [],
      "get"              => [ :first ],
      "getbit"           => [ :first ],
      "getrange"         => [ :first ],
      "getset"           => [ :first ],
      "hset"             => [ :first ],
      "hsetnx"           => [ :first ],
      "hget"             => [ :first ],
      "hincrby"          => [ :first ],
      "hincrbyfloat"     => [ :first ],
      "hmget"            => [ :first ],
      "hmset"            => [ :first ],
      "hdel"             => [ :first ],
      "hexists"          => [ :first ],
      "hlen"             => [ :first ],
      "hkeys"            => [ :first ],
      "hscan"            => [ :first ],
      "hscan_each"       => [ :first ],
      "hvals"            => [ :first ],
      "hgetall"          => [ :first ],
      "incr"             => [ :first ],
      "incrby"           => [ :first ],
      "incrbyfloat"      => [ :first ],
      "info"             => [],
      "keys"             => [ :first, :all ],
      "lastsave"         => [],
      "lindex"           => [ :first ],
      "linsert"          => [ :first ],
      "llen"             => [ :first ],
      "lpop"             => [ :first ],
      "lpush"            => [ :first ],
      "lpushx"           => [ :first ],
      "lrange"           => [ :first ],
      "lrem"             => [ :first ],
      "lset"             => [ :first ],
      "ltrim"            => [ :first ],
      "mapped_hmset"     => [ :first ],
      "mapped_hmget"     => [ :first ],
      "mapped_mget"      => [ :all, :all ],
      "mapped_mset"      => [ :all ],
      "mapped_msetnx"    => [ :all ],
      "mget"             => [ :all ],
      "monitor"          => [ :monitor ],
      "move"             => [ :first ],
      "multi"            => [],
      "mset"             => [ :alternate ],
      "msetnx"           => [ :alternate ],
      "object"           => [ :exclude_first ],
      "persist"          => [ :first ],
      "pexpire"          => [ :first ],
      "pexpireat"        => [ :first ],
      "pfadd"            => [ :first ],
      "pfcount"          => [ :all ],
      "pfmerge"          => [ :all ],
      "ping"             => [],
      "psetex"           => [ :first ],
      "psubscribe"       => [ :all ],
      "pttl"             => [ :first ],
      "publish"          => [ :first ],
      "punsubscribe"     => [ :all ],
      "quit"             => [],
      "randomkey"        => [],
      "rename"           => [ :all ],
      "renamenx"         => [ :all ],
      "restore"          => [ :first ],
      "rpop"             => [ :first ],
      "rpoplpush"        => [ :all ],
      "rpush"            => [ :first ],
      "rpushx"           => [ :first ],
      "sadd"             => [ :first ],
      "save"             => [],
      "scard"            => [ :first ],
      "scan"             => [ :scan_style, :second ],
      "scan_each"        => [ :scan_style, :all ],
      "script"           => [],
      "sdiff"            => [ :all ],
      "sdiffstore"       => [ :all ],
      "select"           => [],
      "set"              => [ :first ],
      "setbit"           => [ :first ],
      "setex"            => [ :first ],
      "setnx"            => [ :first ],
      "setrange"         => [ :first ],
      "shutdown"         => [],
      "sinter"           => [ :all ],
      "sinterstore"      => [ :all ],
      "sismember"        => [ :first ],
      "slaveof"          => [],
      "smembers"         => [ :first ],
      "smove"            => [ :exclude_last ],
      "sort"             => [ :sort  ],
      "spop"             => [ :first ],
      "srandmember"      => [ :first ],
      "srem"             => [ :first ],
      "sscan"            => [ :first ],
      "sscan_each"       => [ :first ],
      "strlen"           => [ :first ],
      "subscribe"        => [ :all ],
      "sunion"           => [ :all ],
      "sunionstore"      => [ :all ],
      "ttl"              => [ :first ],
      "type"             => [ :first ],
      "unsubscribe"      => [ :all ],
      "unwatch"          => [ :all ],
      "watch"            => [ :all ],
      "zadd"             => [ :first ],
      "zcard"            => [ :first ],
      "zcount"           => [ :first ],
      "zincrby"          => [ :first ],
      "zinterstore"      => [ :exclude_options ],
      "zrange"           => [ :first ],
      "zrangebyscore"    => [ :first ],
      "zrank"            => [ :first ],
      "zrem"             => [ :first ],
      "zremrangebyrank"  => [ :first ],
      "zremrangebyscore" => [ :first ],
      "zrevrange"        => [ :first ],
      "zrevrangebyscore" => [ :first ],
      "zrevrank"         => [ :first ],
      "zscan"            => [ :first ],
      "zscan_each"       => [ :first ],
      "zscore"           => [ :first ],
      "zunionstore"      => [ :exclude_options ],
      "[]"               => [ :first ],
      "[]="              => [ :first ]
    }

    # Support 1.8.7 by providing a namespaced reference to Enumerable::Enumerator
    Enumerator = Enumerable::Enumerator unless defined?(::Enumerator)

    attr_writer :namespace
    attr_reader :redis
    attr_accessor :warning

    def initialize(namespace, options = {})
      @namespace = namespace
      @redis = options[:redis] || Redis.current
      @warning = !!options.fetch(:warning) do
                   !ENV['REDIS_NAMESPACE_QUIET']
                 end
      @deprecations = !!options.fetch(:deprecations) do
                        ENV['REDIS_NAMESPACE_DEPRECATIONS']
                      end
    end

    def deprecations?
      @deprecations
    end

    def warning?
      @warning
    end

    def client
      @redis.client
    end

    # Ruby defines a now deprecated type method so we need to override it here
    # since it will never hit method_missing
    def type(key)
      call_with_namespace(:type, key)
    end

    alias_method :self_respond_to?, :respond_to?

    # emulate Ruby 1.9+ and keep respond_to_missing? logic together.
    def respond_to?(command, include_private=false)
      super or respond_to_missing?(command, include_private)
    end

    def keys(query = nil)
      call_with_namespace(:keys, query || '*')
    end

    def multi(&block)
      if block_given?
        namespaced_block(:multi, &block)
      else
        call_with_namespace(:multi)
      end
    end

    def pipelined(&block)
      namespaced_block(:pipelined, &block)
    end

    def namespace(desired_namespace = nil)
      if desired_namespace
        yield Redis::Namespace.new(desired_namespace,
                                   :redis => @redis)
      end

      @namespace
    end

    def exec
      call_with_namespace(:exec)
    end

    def eval(*args)
      call_with_namespace(:eval, *args)
    end

    def method_missing(command, *args, &block)
      normalized_command = command.to_s.downcase

      if COMMANDS.include?(normalized_command)
        call_with_namespace(command, *args, &block)
      elsif @redis.respond_to?(normalized_command) && !deprecations?
        # blind passthrough is deprecated and will be removed in 2.0
        # redis-namespace does not know how to handle this command.
        # Passing it to @redis as is, where redis-namespace shows
        # a warning message if @warning is set.
        if warning?
          call_site = caller.reject { |l| l.start_with?(__FILE__) }.first
          warn("Passing '#{command}' command to redis as is; blind " +
               "passthrough has been deprecated and will be removed in " +
               "redis-namespace 2.0 (at #{call_site})")
        end
        @redis.send(command, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(command, include_all=false)
      return true if COMMANDS.include?(command.to_s.downcase)

      # blind passthrough is deprecated and will be removed in 2.0
      if @redis.respond_to?(command, include_all) && !deprecations?
        return true
      end

      defined?(super) && super
    end

    def call_with_namespace(command, *args, &block)
      handling = COMMANDS[command.to_s.downcase]

      if handling.nil?
        fail("Redis::Namespace does not know how to handle '#{command}'.")
      end

      (before, after) = handling

      # Add the namespace to any parameters that are keys.
      case before
      when :first
        args[0] = add_namespace(args[0]) if args[0]
      when :all
        args = add_namespace(args)
      when :exclude_first
        first = args.shift
        args = add_namespace(args)
        args.unshift(first) if first
      when :exclude_last
        last = args.pop unless args.length == 1
        args = add_namespace(args)
        args.push(last) if last
      when :exclude_options
        if args.last.is_a?(Hash)
          last = args.pop
          args = add_namespace(args)
          args.push(last)
        else
          args = add_namespace(args)
        end
      when :alternate
        args.each_with_index { |a, i| args[i] = add_namespace(a) if i.even? }
      when :sort
        args[0] = add_namespace(args[0]) if args[0]
        if args[1].is_a?(Hash)
          [:by, :store].each do |key|
            args[1][key] = add_namespace(args[1][key]) if args[1][key]
          end

          args[1][:get] = Array(args[1][:get])

          args[1][:get].each_index do |i|
            args[1][:get][i] = add_namespace(args[1][:get][i]) unless args[1][:get][i] == "#"
          end
        end
      when :eval_style
        # redis.eval() and evalsha() can either take the form:
        #
        #   redis.eval(script, [key1, key2], [argv1, argv2])
        #
        # Or:
        #
        #   redis.eval(script, :keys => ['k1', 'k2'], :argv => ['arg1', 'arg2'])
        #
        # This is a tricky + annoying special case, where we only want the `keys`
        # argument to be namespaced.
        if args.last.is_a?(Hash)
          args.last[:keys] = add_namespace(args.last[:keys])
        else
          args[1] = add_namespace(args[1])
        end
      when :scan_style
        options = (args.last.kind_of?(Hash) ? args.pop : {})
        options[:match] = add_namespace(options.fetch(:match, '*'))
        args << options

        if block
          original_block = block
          block = proc { |key| original_block.call rem_namespace(key) }
        end
      end

      # Dispatch the command to Redis and store the result.
      result = @redis.send(command, *args, &block)

      # Don't try to remove namespace from a Redis::Future, you can't.
      return result if result.is_a?(Redis::Future)

      # Remove the namespace from results that are keys.
      case after
      when :all
        result = rem_namespace(result)
      when :first
        result[0] = rem_namespace(result[0]) if result
      when :second
        result[1] = rem_namespace(result[1]) if result
      end

      result
    end

  private

    def namespaced_block(command, &block)
      redis.send(command) do |r|
        begin
          original, @redis = @redis, r
          yield self
        ensure
          @redis = original
        end
      end
    end

    def add_namespace(key)
      return key unless key && @namespace

      case key
      when Array
        key.map {|k| add_namespace k}
      when Hash
        Hash[*key.map {|k, v| [ add_namespace(k), v ]}.flatten]
      else
        "#{@namespace}:#{key}"
      end
    end

    def rem_namespace(key)
      return key unless key && @namespace

      case key
      when Array
        key.map {|k| rem_namespace k}
      when Hash
        Hash[*key.map {|k, v| [ rem_namespace(k), v ]}.flatten]
      when Enumerator
        create_enumerator do |yielder|
          key.each { |k| yielder.yield rem_namespace(k) }
        end
      else
        key.to_s.sub(/\A#{@namespace}:/, '')
      end
    end

    def create_enumerator(&block)
      # Enumerator in 1.8.7 *requires* a single argument, so we need to use
      # its Generator class, which matches the block syntax of 1.9.x's
      # Enumerator class.
      if RUBY_VERSION.start_with?('1.8')
        require 'generator' unless defined?(Generator)
        Generator.new(&block).to_enum
      else
        Enumerator.new(&block)
      end
    end
  end
end
