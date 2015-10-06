module InlineSvg::TransformPipeline::Transformations
  class PreserveAspectRatio < Transformation
    def transform(doc)
      doc = Nokogiri::XML::Document.parse(doc.to_html)
      svg = doc.at_css 'svg'
      svg['preserveAspectRatio'] = self.value
      doc
    end
  end
end
