require 'inline_svg/transform_pipeline'

describe InlineSvg::TransformPipeline::Transformations::Height do
  it "adds height attribute to a SVG document" do
    document = Nokogiri::XML::Document.parse('<svg>Some document</svg>')
    transformation = InlineSvg::TransformPipeline::Transformations::Height.create_with_value("5%")

    expect(transformation.transform(document).to_html).to eq(
      "<svg height=\"5%\">Some document</svg>\n"
    )
  end
end
