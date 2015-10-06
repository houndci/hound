module InlineSvg::TransformPipeline
  module Transformations
    class NoComment < Transformation
      def transform(doc)
        doc = Loofah::HTML::DocumentFragment.parse(doc.to_html)
        doc.scrub!(:strip)
      end
    end
  end
end
