require 'raven/error'

module Raven
  module Transports
    class Transport

      attr_accessor :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def send_event#(auth_header, data, options = {})
        raise NotImplementedError.new('Abstract method not implemented')
      end

      protected

      def verify_configuration
        configuration.verify!
      end
    end
  end
end
