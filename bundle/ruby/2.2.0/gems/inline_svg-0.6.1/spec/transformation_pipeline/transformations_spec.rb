require 'inline_svg'
require 'inline_svg/transform_pipeline'

class ACustomTransform < InlineSvg::CustomTransformation
  def transform(doc)
    doc
  end
end

describe InlineSvg::TransformPipeline::Transformations do
  context "looking up transformations" do
    it "returns built-in transformations when parameters are supplied" do
      transformations = InlineSvg::TransformPipeline::Transformations.lookup(
        nocomment: 'irrelevant',
        class: 'irrelevant',
        title: 'irrelevant',
        desc: 'irrelevant',
        size: 'irrelevant',
        height: 'irrelevant',
        width: 'irrelevant',
        id: 'irrelevant',
        data: 'irrelevant',
        preserve_aspect_ratio: 'irrelevant',
      )

      expect(transformations.map(&:class)).to match_array([
        InlineSvg::TransformPipeline::Transformations::NoComment,
        InlineSvg::TransformPipeline::Transformations::ClassAttribute,
        InlineSvg::TransformPipeline::Transformations::Title,
        InlineSvg::TransformPipeline::Transformations::Description,
        InlineSvg::TransformPipeline::Transformations::Size,
        InlineSvg::TransformPipeline::Transformations::Height,
        InlineSvg::TransformPipeline::Transformations::Width,
        InlineSvg::TransformPipeline::Transformations::IdAttribute,
        InlineSvg::TransformPipeline::Transformations::DataAttributes,
        InlineSvg::TransformPipeline::Transformations::PreserveAspectRatio
      ])
    end

    it "returns a benign transformation when asked for an unknown transform" do
      transformations = InlineSvg::TransformPipeline::Transformations.lookup(
        not_a_real_transform: 'irrelevant'
      )

      expect(transformations.map(&:class)).to match_array([
        InlineSvg::TransformPipeline::Transformations::NullTransformation
      ])
    end

    it "does not return a transformation when a value is not supplied" do
      transformations = InlineSvg::TransformPipeline::Transformations.lookup(
        title: nil
      )

      expect(transformations.map(&:class)).to match_array([])
    end
  end

  context "custom transformations" do
    before(:each) do
      InlineSvg.configure do |config|
        config.add_custom_transformation({transform: ACustomTransform, attribute: :my_transform})
      end
    end

    after(:each) do
      InlineSvg.reset_configuration!
    end

    it "returns configured custom transformations" do
      transformations = InlineSvg::TransformPipeline::Transformations.lookup(
        my_transform: :irrelevant
      )

      expect(transformations.map(&:class)).to match_array([ACustomTransform])
    end
  end

end
