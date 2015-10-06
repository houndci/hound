module InlineSvg::TransformPipeline::Transformations
  class Title < Transformation
    def transform(doc)
      doc = Nokogiri::XML::Document.parse(doc.to_html)
      node = Nokogiri::XML::Node.new('title', doc)
      node.content = value
      doc.at_css('svg').add_child(node)
      doc
    end
  end
end
