module Raven
  class Processor::RemoveStacktrace < Processor

    def process(value)
      if value[:exception]
        value[:exception][:values].map do |single_exception|
          single_exception.delete(:stacktrace) if single_exception[:stacktrace]
        end
      end

      value
    end

  end
end
