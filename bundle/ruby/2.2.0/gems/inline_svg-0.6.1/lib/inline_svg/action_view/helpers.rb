require 'action_view/helpers' if defined?(Rails)
require 'action_view/context' if defined?(Rails)

module InlineSvg
  module ActionView
    module Helpers
      def inline_svg(filename, transform_params={})
        begin
          svg_file = AssetFile.named(filename)
        rescue InlineSvg::AssetFile::FileNotFound
          return "<svg><!-- SVG file not found: '#{filename}' --></svg>".html_safe
        end

        InlineSvg::TransformPipeline.generate_html_from(svg_file, transform_params).html_safe
      end
    end
  end
end
