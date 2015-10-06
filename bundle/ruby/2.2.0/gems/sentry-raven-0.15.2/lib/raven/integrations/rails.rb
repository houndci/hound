require 'raven'
require 'rails'

module Raven
  class Rails < ::Rails::Railtie
    initializer "raven.use_rack_middleware" do |app|
      app.config.middleware.insert 0, "Raven::Rack"
    end

    initializer 'raven.action_controller' do
      ActiveSupport.on_load :action_controller do
        require 'raven/integrations/rails/controller_methods'
        include Raven::Rails::ControllerMethods
      end
    end

    config.after_initialize do
      Raven.configure do |config|
        config.logger ||= ::Rails.logger
        config.project_root ||= ::Rails.root
      end

      if Raven.configuration.catch_debugged_exceptions
        if defined?(::ActionDispatch::DebugExceptions)
          require 'raven/integrations/rails/middleware/debug_exceptions_catcher'
          ::ActionDispatch::DebugExceptions.send(:include, Raven::Rails::Middleware::DebugExceptionsCatcher)
        elsif defined?(::ActionDispatch::ShowExceptions)
          require 'raven/integrations/rails/middleware/debug_exceptions_catcher'
          ::ActionDispatch::ShowExceptions.send(:include, Raven::Rails::Middleware::DebugExceptionsCatcher)
        end
      end
    end

    rake_tasks do
      require 'raven/integrations/tasks'
    end

    runner do
      Raven.capture
    end
  end
end
