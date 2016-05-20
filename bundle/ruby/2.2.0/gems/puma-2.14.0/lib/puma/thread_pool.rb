require 'thread'

module Puma
  # A simple thread pool management object.
  #
  class ThreadPool

    # Maintain a minimum of +min+ and maximum of +max+ threads
    # in the pool.
    #
    # The block passed is the work that will be performed in each
    # thread.
    #
    def initialize(min, max, *extra, &block)
      @not_empty = ConditionVariable.new
      @not_full = ConditionVariable.new
      @mutex = Mutex.new

      @todo = []

      @spawned = 0
      @waiting = 0

      @min = Integer(min)
      @max = Integer(max)
      @block = block
      @extra = extra

      @shutdown = false

      @trim_requested = 0

      @workers = []

      @auto_trim = nil
      @reaper = nil

      @mutex.synchronize do
        @min.times { spawn_thread }
      end

      @clean_thread_locals = false
    end

    attr_reader :spawned, :trim_requested
    attr_accessor :clean_thread_locals

    # How many objects have yet to be processed by the pool?
    #
    def backlog
      @mutex.synchronize { @todo.size }
    end

    # :nodoc:
    #
    # Must be called with @mutex held!
    #
    def spawn_thread
      @spawned += 1

      th = Thread.new do
        todo  = @todo
        block = @block
        mutex = @mutex
        not_empty = @not_empty
        not_full = @not_full

        extra = @extra.map { |i| i.new }

        while true
          work = nil

          continue = true

          mutex.synchronize do
            while todo.empty?
              if @trim_requested > 0
                @trim_requested -= 1
                continue = false
                break
              end

              if @shutdown
                continue = false
                break
              end

              @waiting += 1
              not_full.signal
              not_empty.wait mutex
              @waiting -= 1
            end

            work = todo.shift if continue
          end

          break unless continue

          if @clean_thread_locals
            Thread.current.keys.each do |key|
              Thread.current[key] = nil unless key == :__recursive_key__
            end
          end

          begin
            block.call(work, *extra)
          rescue Exception
          end
        end

        mutex.synchronize do
          @spawned -= 1
          @workers.delete th
        end
      end

      @workers << th

      th
    end

    private :spawn_thread

    # Add +work+ to the todo list for a Thread to pickup and process.
    def <<(work)
      @mutex.synchronize do
        if @shutdown
          raise "Unable to add work while shutting down"
        end

        @todo << work

        if @waiting < @todo.size and @spawned < @max
          spawn_thread
        end

        @not_empty.signal
      end
    end

    def wait_until_not_full
      @mutex.synchronize do
        until @todo.size - @waiting < @max - @spawned or @shutdown
          @not_full.wait @mutex
        end
      end
    end

    # If too many threads are in the pool, tell one to finish go ahead
    # and exit. If +force+ is true, then a trim request is requested
    # even if all threads are being utilized.
    #
    def trim(force=false)
      @mutex.synchronize do
        if (force or @waiting > 0) and @spawned - @trim_requested > @min
          @trim_requested += 1
          @not_empty.signal
        end
      end
    end

    # If there are dead threads in the pool make them go away while decreasing
    # spwaned counter so that new healty threads could be created again.
    def reap
      @mutex.synchronize do
        dead_workers = @workers.reject(&:alive?)

        dead_workers.each do |worker|
          worker.kill
          @spawned -= 1
        end

        @workers -= dead_workers
      end
    end

    class AutoTrim
      def initialize(pool, timeout)
        @pool = pool
        @timeout = timeout
        @running = false
      end

      def start!
        @running = true

        @thread = Thread.new do
          while @running
            @pool.trim
            sleep @timeout
          end
        end
      end

      def stop
        @running = false
        @thread.wakeup
      end
    end

    def auto_trim!(timeout=5)
      @auto_trim = AutoTrim.new(self, timeout)
      @auto_trim.start!
    end

    class Reaper
      def initialize(pool, timeout)
        @pool = pool
        @timeout = timeout
        @running = false
      end

      def start!
        @running = true

        @thread = Thread.new do
          while @running
            @pool.reap
            sleep @timeout
          end
        end
      end

      def stop
        @running = false
        @thread.wakeup
      end
    end

    def auto_reap!(timeout=5)
      @reaper = Reaper.new(self, timeout)
      @reaper.start!
    end

    # Tell all threads in the pool to exit and wait for them to finish.
    #
    def shutdown
      @mutex.synchronize do
        @shutdown = true
        @not_empty.broadcast
        @not_full.broadcast

        @auto_trim.stop if @auto_trim
        @reaper.stop if @reaper
      end

      # Use this instead of #each so that we don't stop in the middle
      # of each and see a mutated object mid #each
      if !@workers.empty?
          @workers.first.join until @workers.empty?
      end

      @spawned = 0
      @workers = []
    end
  end
end
