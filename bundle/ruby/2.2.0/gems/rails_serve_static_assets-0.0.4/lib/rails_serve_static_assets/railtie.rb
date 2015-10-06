module RailsServeStaticAssets
  class Railtie < Rails::Railtie
    config.before_initialize do
      if Rails.version >= "4.2.0"
        ::Rails.configuration.serve_static_files = true
      else
        ::Rails.configuration.serve_static_assets = true
      end
      ::Rails.configuration.action_dispatch.x_sendfile_header = nil
    end
  end
end
