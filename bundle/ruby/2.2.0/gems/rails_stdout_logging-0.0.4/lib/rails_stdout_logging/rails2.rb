require 'rails_stdout_logging/rails'

module RailsStdoutLogging
  class Rails2 < Rails

    def self.set_logger
      super
      redefine_rails_logger!
      classes.each do |klass_name|
        begin
          klass = constantize(klass_name)
          klass.logger = ::Rails.logger
        rescue NameError => exception
          puts "WARNING: #{exception.message}"
        end
      end
    end

    def redefine_rails_logger!
      class << ::Rails
        def memoized_heroku_logger
          @logger ||= self.heroku_stdout_logger
        end
        alias_method :rails_default_logger, :logger
        alias_method :logger, :memoized_heroku_logger
      end
    end

    def self.classes
      %w(
        ActiveSupport::Dependencies
        ActiveRecord::Base
        ActionController::Base
        ActionMailer::Base
        ActionView::Base
        ActiveResource::Base
      )
    end

    def self.constantize(klass_name)
      klass_name.split("::").inject(Object) { |parent, child| parent.const_get(child) }
    rescue NameError
      raise NameError, "Unable to find #{klass_name}"
    end

  end
end
