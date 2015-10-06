require 'raven/interfaces'

module Raven
  class ExceptionInterface < Interface

    name 'exception'
    attr_accessor :values

    def to_hash(*args)
      data = super(*args)
      if data[:values]
        data[:values] = data[:values].map(&:to_hash)
      end
      data
    end
  end

  register_interface :exception => ExceptionInterface
end
