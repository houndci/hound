module Segment
  class Analytics
    class Response
      attr_reader :status, :error

      # public: Simple class to wrap responses from the API
      #
      #
      def initialize(status = 200, error = nil)
        @status = status
        @error  = error
      end
    end
  end
end

