module Sawyer
  VERSION = "0.6.0"

  class Error < StandardError; end
end

require 'set'

%w(
  resource
  relation
  response
  serializer
  agent
  link_parsers/hal
  link_parsers/simple
).each { |f| require File.expand_path("../sawyer/#{f}", __FILE__) }
