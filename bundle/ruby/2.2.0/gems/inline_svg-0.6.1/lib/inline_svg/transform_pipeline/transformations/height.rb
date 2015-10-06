module InlineSvg::TransformPipeline::Transformations
  class Height < Transformation
    def transform(doc)
      doc = Nokogiri::XML::Document.parse(doc.to_html)
      svg = doc.at_css 'svg'
      svg['height'] = self.value
      doc
    end
  end
end
