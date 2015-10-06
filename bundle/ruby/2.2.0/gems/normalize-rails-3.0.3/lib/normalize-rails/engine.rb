module Normalize
  module Rails
    class Engine < ::Rails::Engine
      initializer "configure assets of normalize-rails", :group => :all do |app|
        app.config.assets.precompile += %w( normalize-rails/*.css )
      end
    end
  end
end
