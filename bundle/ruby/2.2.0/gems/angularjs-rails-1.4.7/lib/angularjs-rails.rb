require "angularjs-rails/version"

module AngularJS
  module Rails
    if defined? ::Rails::Engine
      require "angularjs-rails/engine"
    elsif defined? Sprockets
      require "angularjs-rails/sprockets"
    end
  end
end
