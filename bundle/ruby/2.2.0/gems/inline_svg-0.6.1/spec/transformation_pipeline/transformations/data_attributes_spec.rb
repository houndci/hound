require 'inline_svg/transform_pipeline'

describe InlineSvg::TransformPipeline::Transformations::DataAttributes do
  it "adds a data attribute to a SVG document" do
    document = Nokogiri::XML::Document.parse('<svg>Some document</svg>')
    transformation = InlineSvg::TransformPipeline::Transformations::DataAttributes.create_with_value({some: "value"})

    expect(transformation.transform(document).to_html).to eq(
      "<svg data-some=\"value\">Some document</svg>\n"
    )
  end

  context "when multiple data attributes are supplied" do
    it "adds data attributes to the SVG for each supplied value" do
      document = Nokogiri::XML::Document.parse('<svg>Some document</svg>')
      transformation = InlineSvg::TransformPipeline::Transformations::DataAttributes.
        create_with_value({some: "value", other: "thing"})

      expect(transformation.transform(document).to_html).to eq(
        "<svg data-some=\"value\" data-other=\"thing\">Some document</svg>\n"
      )
    end
  end

  context "when a non-hash is supplied" do
    it "does not update the SVG document" do
      document = Nokogiri::XML::Document.parse('<svg>Some document</svg>')
      transformation = InlineSvg::TransformPipeline::Transformations::DataAttributes.
        create_with_value("some non-hash")

      expect(transformation.transform(document).to_html).to eq(
        "<svg>Some document</svg>\n"
      )
    end
  end
end
