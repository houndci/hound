module InlineSvg::TransformPipeline::Transformations
  class Width < Transformation
    def transform(doc)
      doc = Nokogiri::XML::Document.parse(doc.to_html)
      svg = doc.at_css 'svg'
      svg['width'] = self.value
      doc
    end
  end
end
