require File.expand_path("../boot", __FILE__)
require File.expand_path("lib/redirect_to_configuration")

require "rails/all"

Bundler.require(*Rails.groups)

module Houndapp
  class Application < Rails::Application
    config.load_defaults 5.0
    config.autoload_paths += %W(#{config.root}/lib)
    config.eager_load_paths += %W(#{config.root}/lib)
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.middleware.insert_before Rack::ETag, Rack::Deflater
    config.middleware.insert_before Rack::ETag, RedirectToConfiguration
    config.exceptions_app = routes
  end
end
