require 'raven/interfaces'

module Raven
  class SingleExceptionInterface < Interface

    attr_accessor :type
    attr_accessor :value
    attr_accessor :module
    attr_accessor :stacktrace

    def to_hash(*args)
      data = super(*args)
      if data[:stacktrace]
        data[:stacktrace] = data[:stacktrace].to_hash
      end
      data
    end
  end
end
