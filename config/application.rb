require File.expand_path("../boot", __FILE__)
require File.expand_path("lib/redirect_to_configuration")

require "rails/all"

Bundler.require(:default, Rails.env)

module Houndapp
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_job.queue_adapter = :resque
    config.middleware.insert_before Rack::ETag, Rack::Deflater
    config.middleware.insert_before(
      Rack::ETag,
      RedirectToConfiguration,
    )
    config.exceptions_app = routes

    config.react.jsx_transform_options = {
      optional: ["es7.classProperties"],
    }
    config.react.addons = true
  end
end
