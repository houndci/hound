# Stripe Ruby bindings
# API spec at https://stripe.com/docs/api
require 'cgi'
require 'openssl'
require 'rbconfig'
require 'set'
require 'socket'

require 'rest-client'
require 'json'

# Version
require 'stripe/version'

# API operations
require 'stripe/api_operations/create'
require 'stripe/api_operations/update'
require 'stripe/api_operations/delete'
require 'stripe/api_operations/list'
require 'stripe/api_operations/request'

# Resources
require 'stripe/util'
require 'stripe/stripe_object'
require 'stripe/api_resource'
require 'stripe/singleton_api_resource'
require 'stripe/list_object'
require 'stripe/account'
require 'stripe/balance'
require 'stripe/balance_transaction'
require 'stripe/customer'
require 'stripe/invoice'
require 'stripe/invoice_item'
require 'stripe/charge'
require 'stripe/plan'
require 'stripe/file_upload'
require 'stripe/coupon'
require 'stripe/token'
require 'stripe/event'
require 'stripe/transfer'
require 'stripe/recipient'
require 'stripe/bank_account'
require 'stripe/card'
require 'stripe/subscription'
require 'stripe/application_fee'
require 'stripe/refund'
require 'stripe/reversal'
require 'stripe/application_fee_refund'
require 'stripe/bitcoin_receiver'
require 'stripe/bitcoin_transaction'
require 'stripe/dispute'
require 'stripe/product'
require 'stripe/sku'
require 'stripe/order'

# Errors
require 'stripe/errors/stripe_error'
require 'stripe/errors/api_error'
require 'stripe/errors/api_connection_error'
require 'stripe/errors/card_error'
require 'stripe/errors/invalid_request_error'
require 'stripe/errors/authentication_error'
require 'stripe/errors/rate_limit_error'

module Stripe
  DEFAULT_CA_BUNDLE_PATH = File.dirname(__FILE__) + '/data/ca-certificates.crt'
  @api_base = 'https://api.stripe.com'
  @connect_base = 'https://connect.stripe.com'
  @uploads_base = 'https://uploads.stripe.com'

  @ssl_bundle_path  = DEFAULT_CA_BUNDLE_PATH
  @verify_ssl_certs = true

  @open_timeout = 30
  @read_timeout = 80

  class << self
    attr_accessor :api_key, :api_base, :verify_ssl_certs, :api_version, :connect_base, :uploads_base,
                  :open_timeout, :read_timeout
  end

  def self.api_url(url='', api_base_url=nil)
    (api_base_url || @api_base) + url
  end

  def self.request(method, url, api_key, params={}, headers={}, api_base_url=nil)
    api_base_url = api_base_url || @api_base

    unless api_key ||= @api_key
      raise AuthenticationError.new('No API key provided. ' \
        'Set your API key using "Stripe.api_key = <API-KEY>". ' \
        'You can generate API keys from the Stripe web interface. ' \
        'See https://stripe.com/api for details, or email support@stripe.com ' \
        'if you have any questions.')
    end

    if api_key =~ /\s/
      raise AuthenticationError.new('Your API key is invalid, as it contains ' \
        'whitespace. (HINT: You can double-check your API key from the ' \
        'Stripe web interface. See https://stripe.com/api for details, or ' \
        'email support@stripe.com if you have any questions.)')
    end

    if verify_ssl_certs
      request_opts = {:verify_ssl => OpenSSL::SSL::VERIFY_PEER,
                      :ssl_ca_file => @ssl_bundle_path}
    else
      request_opts = {:verify_ssl => false}
      unless @verify_ssl_warned
        @verify_ssl_warned = true
        $stderr.puts("WARNING: Running without SSL cert verification. " \
          "You should never do this in production. " \
          "Execute 'Stripe.verify_ssl_certs = true' to enable verification.")
      end
    end

    params = Util.objects_to_ids(params)
    url = api_url(url, api_base_url)

    case method.to_s.downcase.to_sym
    when :get, :head, :delete
      # Make params into GET parameters
      url += "#{URI.parse(url).query ? '&' : '?'}#{uri_encode(params)}" if params && params.any?
      payload = nil
    else
      if headers[:content_type] && headers[:content_type] == "multipart/form-data"
        payload = params
      else
        payload = uri_encode(params)
      end
    end

    request_opts.update(:headers => request_headers(api_key).update(headers),
                        :method => method, :open_timeout => open_timeout,
                        :payload => payload, :url => url, :timeout => read_timeout)

    begin
      response = execute_request(request_opts)
    rescue SocketError => e
      handle_restclient_error(e, api_base_url)
    rescue NoMethodError => e
      # Work around RestClient bug
      if e.message =~ /\WRequestFailed\W/
        e = APIConnectionError.new('Unexpected HTTP response code')
        handle_restclient_error(e, api_base_url)
      else
        raise
      end
    rescue RestClient::ExceptionWithResponse => e
      if e.response
        handle_api_error(e.response)
      else
        handle_restclient_error(e, api_base_url)
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      handle_restclient_error(e, api_base_url)
    end

    [parse(response), api_key]
  end

  private

  def self.user_agent
    @uname ||= get_uname
    lang_version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"

    {
      :bindings_version => Stripe::VERSION,
      :lang => 'ruby',
      :lang_version => lang_version,
      :platform => RUBY_PLATFORM,
      :engine => defined?(RUBY_ENGINE) ? RUBY_ENGINE : '',
      :publisher => 'stripe',
      :uname => @uname,
      :hostname => Socket.gethostname,
    }

  end

  def self.get_uname
    if File.exist?('/proc/version')
      File.read('/proc/version').strip
    else
      case RbConfig::CONFIG['host_os']
      when /linux|darwin|bsd|sunos|solaris|cygwin/i
        _uname_uname
      when /mswin|mingw/i
        _uname_ver
      else
        "unknown platform"
      end
    end
  end

  def self._uname_uname
    (`uname -a 2>/dev/null` || '').strip
  rescue Errno::ENOMEM # couldn't create subprocess
    "uname lookup failed"
  end

  def self._uname_ver
    (`ver` || '').strip
  rescue Errno::ENOMEM # couldn't create subprocess
    "uname lookup failed"
  end


  def self.uri_encode(params)
    Util.flatten_params(params).
      map { |k,v| "#{k}=#{Util.url_encode(v)}" }.join('&')
  end

  def self.request_headers(api_key)
    headers = {
      :user_agent => "Stripe/v1 RubyBindings/#{Stripe::VERSION}",
      :authorization => "Bearer #{api_key}",
      :content_type => 'application/x-www-form-urlencoded'
    }

    headers[:stripe_version] = api_version if api_version

    begin
      headers.update(:x_stripe_client_user_agent => JSON.generate(user_agent))
    rescue => e
      headers.update(:x_stripe_client_raw_user_agent => user_agent.inspect,
                     :error => "#{e} (#{e.class})")
    end
  end

  def self.execute_request(opts)
    RestClient::Request.execute(opts)
  end

  def self.parse(response)
    begin
      # Would use :symbolize_names => true, but apparently there is
      # some library out there that makes symbolize_names not work.
      response = JSON.parse(response.body)
    rescue JSON::ParserError
      raise general_api_error(response.code, response.body)
    end

    Util.symbolize_names(response)
  end

  def self.general_api_error(rcode, rbody)
    APIError.new("Invalid response object from API: #{rbody.inspect} " +
                 "(HTTP response code was #{rcode})", rcode, rbody)
  end

  def self.handle_api_error(resp)
    begin
      error_obj = JSON.parse(resp.body)
      error_obj = Util.symbolize_names(error_obj)
      error = error_obj[:error]
      raise StripeError.new unless error && error.is_a?(Hash)

    rescue JSON::ParserError, StripeError
      raise general_api_error(resp.code, resp.body)
    end

    case resp.code
    when 400, 404
      raise invalid_request_error(error, resp, error_obj)
    when 401
      raise authentication_error(error, resp, error_obj)
    when 402
      raise card_error(error, resp, error_obj)
    when 429
      raise rate_limit_error(error, resp, error_obj)
    else
      raise api_error(error, resp, error_obj)
    end

  end

  def self.invalid_request_error(error, resp, error_obj)
    InvalidRequestError.new(error[:message], error[:param], resp.code,
                            resp.body, error_obj, resp.headers)
  end

  def self.authentication_error(error, resp, error_obj)
    AuthenticationError.new(error[:message], resp.code, resp.body, error_obj,
                            resp.headers)
  end

  def self.rate_limit_error(error, resp, error_obj)
    RateLimitError.new(error[:message], resp.code, resp.body, error_obj,
                       resp.headers)
  end

  def self.card_error(error, resp, error_obj)
    CardError.new(error[:message], error[:param], error[:code],
                  resp.code, resp.body, error_obj, resp.headers)
  end

  def self.api_error(error, resp, error_obj)
    APIError.new(error[:message], resp.code, resp.body, error_obj, resp.headers)
  end

  def self.handle_restclient_error(e, api_base_url=nil)
    api_base_url = @api_base unless api_base_url
    connection_message = "Please check your internet connection and try again. " \
        "If this problem persists, you should check Stripe's service status at " \
        "https://twitter.com/stripestatus, or let us know at support@stripe.com."

    case e
    when RestClient::RequestTimeout
      message = "Could not connect to Stripe (#{api_base_url}). #{connection_message}"

    when RestClient::ServerBrokeConnection
      message = "The connection to the server (#{api_base_url}) broke before the " \
        "request completed. #{connection_message}"

    when RestClient::SSLCertificateNotVerified
      message = "Could not verify Stripe's SSL certificate. " \
        "Please make sure that your network is not intercepting certificates. " \
        "(Try going to https://api.stripe.com/v1 in your browser.) " \
        "If this problem persists, let us know at support@stripe.com."

    when SocketError
      message = "Unexpected error communicating when trying to connect to Stripe. " \
        "You may be seeing this message because your DNS is not working. " \
        "To check, try running 'host stripe.com' from the command line."

    else
      message = "Unexpected error communicating with Stripe. " \
        "If this problem persists, let us know at support@stripe.com."

    end

    raise APIConnectionError.new(message + "\n\n(Network error: #{e.message})")
  end
end
