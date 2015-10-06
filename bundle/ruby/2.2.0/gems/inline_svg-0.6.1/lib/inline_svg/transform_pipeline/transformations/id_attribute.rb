module InlineSvg::TransformPipeline::Transformations
  class IdAttribute < Transformation
    def transform(doc)
      doc = Nokogiri::XML::Document.parse(doc.to_html)
      svg = doc.at_css 'svg'
      svg['id'] = self.value
      doc
    end
  end
end
