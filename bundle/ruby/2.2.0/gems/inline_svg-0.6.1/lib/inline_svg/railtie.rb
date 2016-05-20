require 'rails/railtie'
module InlineSvg
  class Railtie < ::Rails::Railtie
    initializer "inline_svg.action_view" do |app|
      ActiveSupport.on_load :action_view do
        require "inline_svg/action_view/helpers"
        include InlineSvg::ActionView::Helpers
      end
    end

    config.after_initialize do |app|
      InlineSvg.configure do |config|
        # In default Rails apps, this will be a fully operational
        # Sprockets::Environment instance
        config.asset_finder = app.instance_variable_get(:@assets)
      end
    end
  end
end
