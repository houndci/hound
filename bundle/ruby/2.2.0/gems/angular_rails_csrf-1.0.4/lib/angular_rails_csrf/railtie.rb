require 'angular_rails_csrf/concern'

module AngularRailsCsrf
  class Railtie < ::Rails::Railtie
    initializer 'angular-rails-csrf' do |app|
      ActiveSupport.on_load(:action_controller) do
        include AngularRailsCsrf::Concern
      end
    end
  end
end
