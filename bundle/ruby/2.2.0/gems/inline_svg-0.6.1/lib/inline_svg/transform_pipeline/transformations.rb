module InlineSvg::TransformPipeline::Transformations
  def self.built_in_transformations
    {
      nocomment: NoComment,
      class: ClassAttribute,
      title: Title,
      desc: Description,
      size: Size,
      height: Height,
      width: Width,
      id: IdAttribute,
      data: DataAttributes,
      preserve_aspect_ratio: PreserveAspectRatio
    }
  end

  def self.custom_transformations
    InlineSvg.configuration.custom_transformations
  end

  def self.all_transformations
    built_in_transformations.merge(custom_transformations)
  end

  def self.lookup(transform_params)
    without_empty_values(transform_params).map do |key, value|
      all_transformations.fetch(key, NullTransformation).create_with_value(value)
    end
  end

  def self.without_empty_values(params)
    params.reject {|key, value| value.nil?}
  end
end

require 'inline_svg/transform_pipeline/transformations/transformation'
require 'inline_svg/transform_pipeline/transformations/no_comment'
require 'inline_svg/transform_pipeline/transformations/class_attribute'
require 'inline_svg/transform_pipeline/transformations/title'
require 'inline_svg/transform_pipeline/transformations/description'
require 'inline_svg/transform_pipeline/transformations/size'
require 'inline_svg/transform_pipeline/transformations/height'
require 'inline_svg/transform_pipeline/transformations/width'
require 'inline_svg/transform_pipeline/transformations/id_attribute'
require 'inline_svg/transform_pipeline/transformations/data_attributes'
require 'inline_svg/transform_pipeline/transformations/preserve_aspect_ratio'
