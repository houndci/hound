require 'segment/analytics/defaults'
require 'segment/analytics/utils'
require 'segment/analytics/version'
require 'segment/analytics/client'
require 'segment/analytics/worker'
require 'segment/analytics/request'
require 'segment/analytics/response'
require 'segment/analytics/logging'

module Segment
  class Analytics
    def initialize options = {}
      Request.stub = options[:stub]
      @client = Segment::Analytics::Client.new options
    end

    def method_missing message, *args, &block
      if @client.respond_to? message
        @client.send message, *args, &block
      else
        super
      end
    end

    def respond_to? method_name, include_private = false
      @client.respond_to?(method_name) || super
    end

    include Logging
  end
end
