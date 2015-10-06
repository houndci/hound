module InlineSvg::TransformPipeline::Transformations
  class ClassAttribute < Transformation
    def transform(doc)
      doc = Nokogiri::XML::Document.parse(doc.to_html)
      svg = doc.at_css 'svg'
      svg['class'] = value
      doc
    end
  end
end
