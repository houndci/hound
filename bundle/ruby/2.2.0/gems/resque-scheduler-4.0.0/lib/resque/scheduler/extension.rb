# vim:fileencoding=utf-8

require_relative 'scheduling_extensions'
require_relative 'delaying_extensions'

module Resque
  module Scheduler
    module Extension
      include SchedulingExtensions
      include DelayingExtensions
    end
  end
end
