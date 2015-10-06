module InlineSvg::TransformPipeline::Transformations
  class DataAttributes < Transformation
    def transform(doc)
      doc = Nokogiri::XML::Document.parse(doc.to_html)
      svg = doc.at_css 'svg'
      with_valid_hash_from(self.value).each_pair do |name, data|
        svg["data-#{name}"] = data
      end
      doc
    end

    def with_valid_hash_from(hash)
      Hash.try_convert(hash) || {}
    end
  end
end
