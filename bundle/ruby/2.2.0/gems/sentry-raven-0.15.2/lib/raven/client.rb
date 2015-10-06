require 'zlib'
require 'base64'

require 'raven/version'
require 'raven/okjson'
require 'raven/transports/http'
require 'raven/transports/udp'

module Raven
  # Encodes events and sends them to the Sentry server.
  class Client
    PROTOCOL_VERSION = '5'
    USER_AGENT = "raven-ruby/#{Raven::VERSION}"
    CONTENT_TYPE = 'application/json'

    attr_accessor :configuration

    def initialize(configuration)
      @configuration = configuration
      @processors = configuration.processors.map { |v| v.new(self) }
      @state = ClientState.new
    end

    def send_event(event)
      return false unless configuration_allows_sending

      # Convert to hash
      event = event.to_hash

      if !@state.should_try?
        Raven.logger.error("Not sending event due to previous failure(s): #{get_log_message(event)}")
        return
      end

      Raven.logger.debug "Sending event #{event[:event_id]} to Sentry"

      content_type, encoded_data = encode(event)

      begin
        transport.send_event(generate_auth_header, encoded_data,
                       :content_type => content_type)
      rescue => e
        failed_send(e, event)
        return
      end

      successful_send

      event
    end

    def send(event)
      Raven.logger.warn "DEPRECATION WARNING: Calling #send on a Client will be \
        removed in Raven-Ruby 0.14! Use #send_event instead!"
      send_event(event)
    end

    private

    def configuration_allows_sending
      if configuration.send_in_current_environment?
        true
      else
        configuration.log_excluded_environment_message
        false
      end
    end

    def encode(event)
      hash = @processors.reduce(event.to_hash) { |memo, p| p.process(memo) }
      encoded = OkJson.encode(hash)

      case configuration.encoding
      when 'gzip'
        ['application/octet-stream', strict_encode64(Zlib::Deflate.deflate(encoded))]
      else
        ['application/json', encoded]
      end
    end

    def get_log_message(event)
      (event && event[:message]) || '<no message value>'
    end

    def transport
      @transport ||=
        case configuration.scheme
        when 'udp'
          Transports::UDP.new(configuration)
        when 'http', 'https'
          Transports::HTTP.new(configuration)
        else
          raise Error, "Unknown transport scheme '#{self.configuration.scheme}'"
        end
    end

    def generate_auth_header
      now = Time.now.to_i.to_s
      fields = {
        'sentry_version' => PROTOCOL_VERSION,
        'sentry_client' => USER_AGENT,
        'sentry_timestamp' => now,
        'sentry_key' => configuration.public_key,
        'sentry_secret' => configuration.secret_key
      }
      'Sentry ' + fields.map { |key, value| "#{key}=#{value}" }.join(', ')
    end

    def strict_encode64(string)
      if Base64.respond_to? :strict_encode64
        Base64.strict_encode64 string
      else # Ruby 1.8
        Base64.encode64(string)[0..-2]
      end
    end

    def successful_send
      @state.success
    end

    def failed_send(e, event)
      @state.failure
      Raven.logger.error "Unable to record event with remote Sentry server (#{e.class} - #{e.message})"
      e.backtrace[0..10].each { |line| Raven.logger.error(line) }
      Raven.logger.error("Failed to submit event: #{get_log_message(event)}")
    end

  end

  class ClientState
    def initialize
      reset
    end

    def should_try?
      return true if @status == :online

      interval = @retry_after || [@retry_number, 6].min ** 2
      return true if Time.now - @last_check >= interval

      false
    end

    def failure(retry_after = nil)
      @status = :error
      @retry_number += 1
      @last_check = Time.now
      @retry_after = retry_after
    end

    def success
      reset
    end

    def reset
      @status = :online
      @retry_number = 0
      @last_check = nil
      @retry_after = nil
    end

    def failed?
      @status == :error
    end
  end
end
