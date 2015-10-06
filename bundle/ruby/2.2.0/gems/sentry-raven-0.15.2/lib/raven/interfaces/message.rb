require 'raven/interfaces'

module Raven
  class MessageInterface < Interface

    name 'sentry.interfaces.Message'
    attr_accessor :message
    attr_accessor :params

    def initialize(*arguments)
      self.params = []
      super(*arguments)
    end
  end

  register_interface :message => MessageInterface
end
