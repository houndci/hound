require 'faraday'

require 'raven/transports'
require 'raven/error'

module Raven
  module Transports
    class HTTP < Transport
      def send_event(auth_header, data, options = {})
        project_id = self.configuration[:project_id]
        path = self.configuration[:path] + "/"

        response = conn.post "#{path}api/#{project_id}/store/" do |req|
          req.headers['Content-Type'] = options[:content_type]
          req.headers['X-Sentry-Auth'] = auth_header
          req.body = data
        end
        Raven.logger.warn "Error from Sentry server (#{response.status}): #{response.body}" unless response.status == 200
        response
      end

      def send(auth_header, data, options = {})
        Raven.logger.warn "DEPRECATION WARNING: Calling #send on a Transport will be \
          removed in Raven-Ruby 0.14! Use #send_event instead!"
        send_event(auth_header, data, options)
      end

      private

      def conn
        @conn ||= begin
          self.verify_configuration

          Raven.logger.debug "Raven HTTP Transport connecting to #{self.configuration.server}"

          ssl_configuration = self.configuration.ssl || {}
          ssl_configuration[:verify] = self.configuration.ssl_verification
          ssl_configuration[:ca_file] = self.configuration.ssl_ca_file

          conn = Faraday.new(
            :url => self.configuration[:server],
            :ssl => ssl_configuration
          ) do |builder|
            builder.adapter(*adapter)
          end

          if self.configuration.proxy
            conn.options[:proxy] = self.configuration.proxy
          end

          if self.configuration.timeout
            conn.options[:timeout] = self.configuration.timeout
          end
          if self.configuration.open_timeout
            conn.options[:open_timeout] = self.configuration.open_timeout
          end

          conn
        end
      end

      def adapter
        configuration.http_adapter || Faraday.default_adapter
      end
    end
  end
end
