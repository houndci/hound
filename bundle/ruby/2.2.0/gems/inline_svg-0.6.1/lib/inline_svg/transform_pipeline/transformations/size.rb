module InlineSvg::TransformPipeline::Transformations
  class Size < Transformation
    def transform(doc)
      doc = Nokogiri::XML::Document.parse(doc.to_html)
      svg = doc.at_css 'svg'
      svg['width'] = width_of(self.value)
      svg['height'] = height_of(self.value)
      doc
    end

    def width_of(value)
      value.split(/\*/).map(&:strip)[0]
    end

    def height_of(value)
      value.split(/\*/).map(&:strip)[1] || width_of(value)
    end
  end
end
