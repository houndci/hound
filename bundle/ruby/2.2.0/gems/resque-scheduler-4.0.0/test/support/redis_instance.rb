# vim:fileencoding=utf-8
require 'socket'
require 'timeout'
require 'fileutils'

class RedisInstance
  class << self
    @running = false
    @port = nil
    @pid = nil
    @waiting = false

    def run_if_needed!
      run! unless @running
    end

    def run!
      ensure_redis_server_present!
      ensure_pid_directory
      reassign_redis_clients
      start_redis_server
      post_boot_waiting_and_such

      @running = true
    end

    def stop!
      $stdout.puts "Sending TERM to Redis (#{pid})..." if $stdout.tty?
      Process.kill('TERM', pid)

      @port = nil
      @running = false
      @pid = nil
    end

    private

    def post_boot_waiting_and_such
      wait_for_pid
      puts "Booted isolated Redis on #{port} with PID #{pid}."

      wait_for_redis_boot

      # Ensure we tear down Redis on Ctrl+C / test failure.
      at_exit { stop! }
    end

    def ensure_redis_server_present!
      unless system('redis-server -v')
        fail "** can't find `redis-server` in your path"
      end
    end

    def wait_for_redis_boot
      Timeout.timeout(10) do
        loop do
          begin
            break if Resque.redis.ping == 'PONG'
          rescue Redis::CannotConnectError
            @waiting = true
          end
        end
        @waiting = false
      end
    end

    def ensure_pid_directory
      FileUtils.mkdir_p(File.dirname(pid_file))
    end

    def reassign_redis_clients
      Resque.redis = Redis.new(
        hostname: '127.0.0.1', port: port, thread_safe: true
      )
    end

    def start_redis_server
      IO.popen('redis-server -', 'w+') do |server|
        server.write(config)
        server.close_write
      end
    end

    def pid
      @pid ||= File.read(pid_file).to_i
    end

    def wait_for_pid
      Timeout.timeout(10) do
        loop { break if File.exist?(pid_file) }
      end
    end

    def port
      @port ||= random_port
    end

    def pid_file
      '/tmp/redis-scheduler-test.pid'
    end

    def config
      <<-EOF
        daemonize yes
        pidfile #{pid_file}
        port #{port}
      EOF
    end

    # Returns a random port in the upper (10000-65535) range.
    def random_port
      ports = (10_000..65_535).to_a

      loop do
        port = ports[rand(ports.size)]
        return port if port_available?('127.0.0.1', port)
      end
    end

    def port_available?(ip, port, seconds = 1)
      Timeout.timeout(seconds) do
        begin
          TCPSocket.new(ip, port).close
          false
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          true
        end
      end
    rescue Timeout::Error
      true
    end
  end
end
