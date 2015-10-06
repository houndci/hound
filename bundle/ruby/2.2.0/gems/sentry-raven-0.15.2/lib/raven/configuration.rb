require 'logger'
require 'uri'

module Raven
  class Configuration

    # Simple server string (setter provided below)
    attr_reader :server

    # Public key for authentication with the Sentry server
    attr_accessor :public_key

    # Secret key for authentication with the Sentry server
    attr_accessor :secret_key

    # Accessors for the component parts of the DSN
    attr_accessor :scheme
    attr_accessor :host
    attr_accessor :port
    attr_accessor :path

    # Project ID number to send to the Sentry server
    attr_accessor :project_id

    # Project directory root
    attr_accessor :project_root

    # Encoding type for event bodies
    attr_reader :encoding

    # Logger to use internally
    attr_accessor :logger

    # Silence ready message
    attr_accessor :silence_ready

    # Number of lines of code context to capture, or nil for none
    attr_accessor :context_lines

    # Whitelist of environments that will send notifications to Sentry
    attr_accessor :environments

    # Include module versions in reports?
    attr_accessor :send_modules

    # Which exceptions should never be sent
    attr_accessor :excluded_exceptions

    # Processors to run on data before sending upstream
    attr_accessor :processors

    # Timeout when waiting for the server to return data in seconds
    attr_accessor :timeout

    # Timeout waiting for the connection to open in seconds
    attr_accessor :open_timeout

    # Should the SSL certificate of the server be verified?
    attr_accessor :ssl_verification

    # The path to the SSL certificate file
    attr_accessor :ssl_ca_file

    # SSl settings passed direactly to faraday's ssl option
    attr_accessor :ssl

    # Proxy information to pass to the HTTP adapter
    attr_accessor :proxy

    attr_reader :current_environment

    # The Faraday adapter to be used. Will default to Net::HTTP when not set.
    attr_accessor :http_adapter

    attr_accessor :server_name

    attr_accessor :release

    # DEPRECATED: This option is now ignored as we use our own adapter.
    attr_accessor :json_adapter

    # Default tags for events
    attr_accessor :tags

    # Optional Proc to be used to send events asynchronously.
    attr_reader :async

    # Exceptions from these directories to be ignored
    attr_accessor :app_dirs_pattern

    # Catch exceptions before they're been processed by
    # ActionDispatch::ShowExceptions or ActionDispatch::DebugExceptions
    attr_accessor :catch_debugged_exceptions

    # Provide a configurable callback to determine event capture
    attr_accessor :should_capture

    # additional fields to sanitize
    attr_accessor :sanitize_fields

    # Sanitize values that look like credit card numbers
    attr_accessor :sanitize_credit_cards

    IGNORE_DEFAULT = ['ActiveRecord::RecordNotFound',
                      'ActionController::RoutingError',
                      'ActionController::InvalidAuthenticityToken',
                      'CGI::Session::CookieStore::TamperedWithCookie',
                      'ActionController::UnknownAction',
                      'AbstractController::ActionNotFound',
                      'Mongoid::Errors::DocumentNotFound']

    def initialize
      self.server = ENV['SENTRY_DSN'] if ENV['SENTRY_DSN']
      @context_lines = 3
      self.current_environment = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'default'
      self.send_modules = true
      self.excluded_exceptions = IGNORE_DEFAULT
      self.processors = [Raven::Processor::RemoveCircularReferences, Raven::Processor::UTF8Conversion, Raven::Processor::SanitizeData]
      self.ssl_verification = true
      self.encoding = 'gzip'
      self.timeout = 1
      self.open_timeout = 1
      self.proxy = nil
      self.tags = {}
      self.async = false
      self.catch_debugged_exceptions = true
      self.sanitize_fields = []
      self.sanitize_credit_cards = true
      self.environments = []
    end

    def server=(value)
      uri = URI.parse(value)
      uri_path = uri.path.split('/')

      if uri.user
        # DSN-style string
        @project_id = uri_path.pop
        @public_key = uri.user
        @secret_key = uri.password
      end

      @scheme = uri.scheme
      @host = uri.host
      @port = uri.port if uri.port
      @path = uri_path.join('/')

      # For anyone who wants to read the base server string
      @server = "#{@scheme}://#{@host}"
      @server << ":#{@port}" unless @port == { 'http' => 80, 'https' => 443 }[@scheme]
      @server << @path
    end

    def encoding=(encoding)
      raise Error.new('Unsupported encoding') unless ['gzip', 'json'].include? encoding
      @encoding = encoding
    end

    alias_method :dsn=, :server=

    def async=(value)
      raise ArgumentError.new("async must be callable (or false to disable)") unless (value == false || value.respond_to?(:call))
      @async = value
    end

    alias_method :async?, :async

    # Allows config options to be read like a hash
    #
    # @param [Symbol] option Key for a given attribute
    def [](option)
      send(option)
    end

    def current_environment=(environment)
      @current_environment = environment.to_s
    end

    def send_in_current_environment?
      !!server && (environments.empty? || environments.include?(current_environment))
    end

    def log_excluded_environment_message
      Raven.logger.debug "Event not sent due to excluded environment: #{current_environment}"
    end

    def verify!
      raise Error.new('No server specified') unless server
      raise Error.new('No public key specified') unless public_key
      raise Error.new('No secret key specified') unless secret_key
      raise Error.new('No project ID specified') unless project_id
    end
  end
end
