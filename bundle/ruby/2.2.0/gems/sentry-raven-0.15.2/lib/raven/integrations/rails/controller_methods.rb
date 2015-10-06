module Raven
  class Rails
    module ControllerMethods
      def capture_message(message, options = {})
        Raven::Rack.capture_message(message, request.env, options)
      end

      def capture_exception(exception, options = {})
        Raven::Rack.capture_exception(exception, request.env, options)
      end
    end
  end
end
