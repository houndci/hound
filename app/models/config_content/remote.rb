# frozen_string_literal: true

class ConfigContent
  class Remote
    extend Forwardable

    def_delegators :response, :body, :status, :success?

    def initialize(url)
      @url = url
    end

    def load
      if success?
        body
      else
        raise ContentError, "#{status} #{body}"
      end
    end

    private

    attr_reader :url

    def connection
      Faraday.new
    end

    def response
      connection.get(url)
    end
  end
end
