class IO
  # We need to use this for a jruby work around on both 1.8 and 1.9.
  # So this either creates the constant (on 1.8), or harmlessly
  # reopens it (on 1.9).
  module WaitReadable
  end
end

require 'puma/detect'

if Puma::IS_JRUBY
  # We have to work around some OpenSSL buffer/io-readiness bugs
  # so we pull it in regardless of if the user is binding
  # to an SSL socket
  require 'openssl'
end

module Puma

  class ConnectionError < RuntimeError; end

  class Client
    include Puma::Const

    def initialize(io, env=nil)
      @io = io
      @to_io = io.to_io
      @proto_env = env
      if !env
        @env = nil
      else
        @env = env.dup
      end

      @parser = HttpParser.new
      @parsed_bytes = 0
      @read_header = true
      @ready = false

      @body = nil
      @buffer = nil
      @tempfile = nil

      @timeout_at = nil

      @requests_served = 0
      @hijacked = false
    end

    attr_reader :env, :to_io, :body, :io, :timeout_at, :ready, :hijacked,
                :tempfile

    def inspect
      "#<Puma::Client:0x#{object_id.to_s(16)} @ready=#{@ready.inspect}>"
    end

    # For the hijack protocol (allows us to just put the Client object
    # into the env)
    def call
      @hijacked = true
      env[HIJACK_IO] ||= @io
    end

    def in_data_phase
      !@read_header
    end

    def set_timeout(val)
      @timeout_at = Time.now + val
    end

    def reset(fast_check=true)
      @parser.reset
      @read_header = true
      @env = @proto_env.dup
      @body = nil
      @tempfile = nil
      @parsed_bytes = 0
      @ready = false

      if @buffer
        @parsed_bytes = @parser.execute(@env, @buffer, @parsed_bytes)

        if @parser.finished?
          return setup_body
        elsif @parsed_bytes >= MAX_HEADER
          raise HttpParserError,
            "HEADER is longer than allowed, aborting client early."
        end

        return false
      elsif fast_check &&
            IO.select([@to_io], nil, nil, FAST_TRACK_KA_TIMEOUT)
        return try_to_finish
      end
    end

    def close
      begin
        @io.close
      rescue IOError
      end
    end

    # The object used for a request with no body. All requests with
    # no body share this one object since it has no state.
    EmptyBody = NullIO.new

    def setup_body
      @in_data_phase = true
      body = @parser.body
      cl = @env[CONTENT_LENGTH]

      unless cl
        @buffer = body.empty? ? nil : body
        @body = EmptyBody
        @requests_served += 1
        @ready = true
        return true
      end

      remain = cl.to_i - body.bytesize

      if remain <= 0
        @body = StringIO.new(body)
        @buffer = nil
        @requests_served += 1
        @ready = true
        return true
      end

      if remain > MAX_BODY
        @body = Tempfile.new(Const::PUMA_TMP_BASE)
        @body.binmode
        @tempfile = @body
      else
        # The body[0,0] trick is to get an empty string in the same
        # encoding as body.
        @body = StringIO.new body[0,0]
      end

      @body.write body

      @body_remain = remain

      @read_header = false

      return false
    end

    def try_to_finish
      return read_body unless @read_header

      begin
        data = @io.read_nonblock(CHUNK_SIZE)
      rescue Errno::EAGAIN
        return false
      rescue SystemCallError, IOError
        raise ConnectionError, "Connection error detected during read"
      end

      if @buffer
        @buffer << data
      else
        @buffer = data
      end

      @parsed_bytes = @parser.execute(@env, @buffer, @parsed_bytes)

      if @parser.finished?
        return setup_body
      elsif @parsed_bytes >= MAX_HEADER
        raise HttpParserError,
          "HEADER is longer than allowed, aborting client early."
      end
      
      false
    end

    if IS_JRUBY
      def jruby_start_try_to_finish
        return read_body unless @read_header

        begin
          data = @io.sysread_nonblock(CHUNK_SIZE)
        rescue OpenSSL::SSL::SSLError => e
          return false if e.kind_of? IO::WaitReadable
          raise e
        end

        if @buffer
          @buffer << data
        else
          @buffer = data
        end

        @parsed_bytes = @parser.execute(@env, @buffer, @parsed_bytes)

        if @parser.finished?
          return setup_body
        elsif @parsed_bytes >= MAX_HEADER
          raise HttpParserError,
            "HEADER is longer than allowed, aborting client early."
        end

        false
      end

      def eagerly_finish
        return true if @ready

        if @io.kind_of? OpenSSL::SSL::SSLSocket
          return true if jruby_start_try_to_finish
        end

        return false unless IO.select([@to_io], nil, nil, 0)
        try_to_finish
      end

    else

      def eagerly_finish
        return true if @ready
        return false unless IO.select([@to_io], nil, nil, 0)
        try_to_finish
      end
    end # IS_JRUBY

    def finish
      return true if @ready
      until try_to_finish
        IO.select([@to_io], nil, nil)
      end
      true
    end

    def read_body
      # Read an odd sized chunk so we can read even sized ones
      # after this
      remain = @body_remain

      if remain > CHUNK_SIZE
        want = CHUNK_SIZE
      else
        want = remain
      end

      begin
        chunk = @io.read_nonblock(want)
      rescue Errno::EAGAIN
        return false
      rescue SystemCallError, IOError
        raise ConnectionError, "Connection error detected during read"
      end

      # No chunk means a closed socket
      unless chunk
        @body.close
        @buffer = nil
        @requests_served += 1
        @ready = true
        raise EOFError
      end

      remain -= @body.write(chunk)

      if remain <= 0
        @body.rewind
        @buffer = nil
        @requests_served += 1
        @ready = true
        return true
      end

      @body_remain = remain

      false
    end

    def write_400
      begin
        @io << ERROR_400_RESPONSE
      rescue StandardError
      end
    end

    def write_408
      begin
        @io << ERROR_408_RESPONSE
      rescue StandardError
      end
    end

    def write_500
      begin
        @io << ERROR_500_RESPONSE
      rescue StandardError
      end
    end
  end
end
